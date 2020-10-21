package main

import (
	"bytes"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"math"
	"net/http"
	"os"
	"os/exec"
	"regexp"
	"runtime"
	"strconv"
	"strings"

	log "github.com/sirupsen/logrus"
)

var verbose bool
var check bool
var awsByol13Platforms = [4]string{"Red Hat Enterprise Linux Server 7.7", "Red Hat Enterprise Linux Server 7.8",
"Red Hat Enterprise Linux 8.1", "Red Hat Enterprise Linux 8.2"}
var scaleOSDepends = [8]string{"ksh", "libaio", "m4", "kernel-devel", "cpp", "gcc", "gcc-c", "kernel-headers"}
var scaleFaq = "https://www.ibm.com/support/knowledgecenter/STXKQY/gpfsclustersfaq.html#linux__rhelkerntable"
var utilityMessage = `======================================================================
| Note:                                                              |
| 1. This utility should only be used for initial screening of AWS   |
|    custom AMI meant for deployment of IBM Spectrum Stack BYOL 1.3  |
|    release.                                                        |
| 2. It is advised to follow AWS best practices for building AMI's.  |
======================================================================`

func getAWSinstanceID() (instanceid []byte) {
	res, err := http.Get("http://169.254.169.254/latest/meta-data/instance-id")
	if err != nil {
		log.Fatalf("Could not identify AWS platform.\nReason: %v", err)
	}
	contents, err := ioutil.ReadAll(res.Body)
	res.Body.Close()
	if err != nil {
		log.Fatalf("Could not identify AWS platform.\nReason: %v", err)
	} else {
		instanceid = contents
	}

	return
}

func getOSplatform() (osPlatform string, osVersionid string) {
	outBytes, err := ioutil.ReadFile("/etc/os-release")
	if err != nil {
		log.Fatalf("Reading file (/etc/release) failed: %v", err)
	}

	strOutput := string(outBytes)
	reName := regexp.MustCompile("NAME=\"(.*)\"")
	matchName := reName.FindStringSubmatch(strOutput)
	if matchName != nil {
		osPlatform = matchName[1]
	} else {
		log.Fatalf("Could not identify OS platform.")
	}
	reVersion := regexp.MustCompile("VERSION_ID=\"(.*)\"")
	matchVersion := reVersion.FindStringSubmatch(strOutput)
	if matchVersion != nil {
		osVersionid = matchVersion[1]
	} else {
		log.Fatalf("Could not identify OS version")
	}

	return
}

func localCommandExecute(targetCmd string, targetCmdArgs []string) (cmdOut string) {
	var stdout, stderr bytes.Buffer
	cmd := exec.Command(targetCmd, targetCmdArgs...)
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err != nil {
		log.Fatalf("Executing command (%v) failed with (%v)\n", targetCmd, err)
	}
	outStr := string(stdout.Bytes())
	cmdOut = strings.TrimSuffix(outStr, "\n")

	return
}

func main() {
	flag.BoolVar(&verbose, "verbose", false, "Sets verbose level to debug.")
	flag.Parse()
	if verbose {
		log.SetFormatter(&log.TextFormatter{FullTimestamp: true})
		log.SetLevel(log.DebugLevel)
	} else {
		log.SetFormatter(&log.TextFormatter{FullTimestamp: true})
		log.SetLevel(log.InfoLevel)
	}
	fmt.Println(utilityMessage)
	logfile, err := os.OpenFile("/var/log/precheck_customami.log", os.O_RDWR|os.O_CREATE, 0666)
	if err != nil {
		log.Fatalf("Error opening log file: %v", err)
	} else {
		log.Info("Logging in to file: ", "/var/log/precheck_customami.log")
	}
	defer logfile.Close()
	wrt := io.MultiWriter(os.Stdout, logfile)
	log.SetOutput(wrt)

	log.Info("1. Performing AWS platform check")
	getAWSinstanceID()
	log.Debug("Identified cloud platform: ", "AWS")

	log.Info("2. Performing OS, arch check")
	log.Debug("Identified OS flavor: ", runtime.GOOS)
	log.Debug("Identified OS architecture: ", runtime.GOARCH)
	if runtime.GOOS != "linux" {
		log.Fatalf("IBM Spectrum Scale BYOL 1.3 release on AWS supports only \"%v\" flavor", runtime.GOOS)
	}
	if runtime.GOARCH != "amd64" {
		log.Fatalf("IBM Spectrum Scale BYOL 1.3 release on AWS supports only \"%v\" achitecture", runtime.GOARCH)
	}

	log.Info("3. Performing OS platform, version, kernel check")
	platform, version := getOSplatform()
	log.Debug("Identified OS platform: ", platform)
	log.Debug("Identified OS version id: ", version)
	currentKernel := localCommandExecute("uname", []string{"-r"})
	log.Debug("Identified kernel version: ", currentKernel)
	for _, eachplatform := range awsByol13Platforms {
		if eachplatform == platform+" "+version {
			check = true
		}
	}
	if check {
		log.Debugf("Identified OS platform (%v) is supported by BYOL 1.3 release", (platform + " " + version))
		log.Info("For more details related to supported kernel levels, refer to ", scaleFaq)
	} else {
		log.Info("For more details related to supported kernel levels, refer to ", scaleFaq)
		log.Fatalf("Identified OS platform (%v) is NOT supported as AMI for BYOL 1.3 release", (platform + " " + version))
	}

	log.Info("4. Performing root volume size check")
	rootVol := localCommandExecute("df", []string{"-h"})
	reEBSpartitionName := regexp.MustCompile("/dev/xvd([a-z0-9]*)\\s+([0-9]*[GM])\\s+(.*[GM])\\s+(.*[GM])\\s+(.*%)\\s+\\/")
	matchpartitionDetails := reEBSpartitionName.FindStringSubmatch(rootVol)
	if matchpartitionDetails == nil {
		log.Fatalf("Could not obtain root EBS parition.")
	} else {
		log.Debug("Identified root EBS parition: ", "/dev/xvd"+matchpartitionDetails[1])
		log.Debug("Identified root EBS size: ", matchpartitionDetails[2])
		log.Debug("Identified root EBS available size: ", matchpartitionDetails[4])
		log.Debug("Identified root EBS use percentage: ", matchpartitionDetails[5])
	}
	if strings.Contains(matchpartitionDetails[4], "G") {
		sizeGB := strings.Trim(matchpartitionDetails[4], "G")
		intsizeGB, _ := strconv.ParseFloat(sizeGB, 1)
		if math.Ceil(intsizeGB) <= 10 {
			fmt.Println("Identified root EBS available size is less than 10G.")
			fmt.Println("It is recommended to keep atleast 10GB of free space in root EBS volume for IBM Spectrum Scale installation.")
			fmt.Println("However it is advised to keep atleast 100GB of free space in root EBS volume for better performance.")
		}
	} else if strings.Contains(matchpartitionDetails[4], "M") {
		sizeMB := strings.Trim(matchpartitionDetails[4], "M")
		intsizeMB, _ := strconv.ParseFloat(sizeMB, 1)
		if math.Ceil(intsizeMB) <= 10240 {
			fmt.Println("Identified root EBS available size is less than 10G.")
			fmt.Println("It is recommended to keep atleast 10GB of free space in root EBS volume for IBM Spectrum Scale installation.")
			fmt.Println("However it is advised to keep atleast 100GB of free space in root EBS volume for better performance.")
		}
	}

	log.Info("5. Performing OS dependencies (required for IBM Spectrum Scale) check")
	allInstalledRPMs := localCommandExecute("rpm", []string{"-qa"})
	for _, osdep := range scaleOSDepends {
		rpmmatch, _ := regexp.MatchString(osdep, allInstalledRPMs)
		if rpmmatch {
			log.Debugf("OS dependency RPM (%v) installed", osdep)
		} else {
			log.Warnf("OS dependency RPM (%v) not installed (which could lead to deployment failure)", osdep)
		}
	}

	log.Info("6. Performing IBM Spectrum Scale past installations check")
	gpfsrpmamtch, _ := regexp.MatchString("gpfs", allInstalledRPMs)
	if gpfsrpmamtch {
		log.Infof("Identified GPFS RPMs installation")
		log.Fatalln("Any existing installation / version of GPFS RPMs are NOT supported inside of AMI for BYOL 1.3 release")
	} else {
		log.Debug("No versions of gpfs RPMs found.")
	}
	log.Info("=====================================================================")
	log.Info(" All tests related to IBM Spectrum Scale AWS BYOL 1.3 are completed. ")
	log.Info(" Kindly advised to follow the best practices for building AMI's. ")
	log.Info("=====================================================================")
}
