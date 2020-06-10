#!/bin/bash
# © Copyright IBM Corporation 2018
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
​
declare -a IBM_SPECTRUM_SCALE_SUPPORTED_OS=('rhel 7.7' 'rhel 7.8' 'rhel 8.0' 'rhel 8.1')
declare -a IBM_SPECTRUM_SCALE_SUPPORTED_KERNEL=('3.10.0' '4.18.0')
declare -a IBM_SPECTRUM_SCALE_DEPENDENCY_PACKAGES=('cpp' 'gcc' 'gcc-c++' 'binutils' 'python2' 'python3')
​
function INFO() {
  # This funtion would print info messages
  local msg="$1"
  echo "[INFO] $msg"
}
​
function WARN() {
  # This funtion would print warning messages
  local msg="$1"
  echo "[WARN] $msg"
}
​
function ERROR() {
  # This funtion would print error messages
  local msg="$1"
  echo "[ERROR] $msg"
}
​
function status() {
  # This function would be checking status when command executes
  if [ "${?}" -eq 0 ]; then
    return 0
  else
    return 1
  fi
}
​
function valid_os() {
  # This function would validate the Operation System support for IBM Spectrum Scale
  if [ -f /etc/os-release ]; then
    source /etc/os-release
    os_version=$ID' '$VERSION_ID
    INFO "Found Operating System: ${os_version}"
    for item in "${IBM_SPECTRUM_SCALE_SUPPORTED_OS[@]}"
    do
      if [[ "$os_version" ==  "$item" ]]; then
        return 0
      fi
    done
    ERROR "Operating system is not supported by IBM Spectrum Scale."
    return 1
  else
    ERROR "Unable to identify the Operating System."
    return 1
  fi
}
​
function valid_kernel() {
  # This function would validate the Kernel version support for IBM Spectrum Scale
  identify_kernel=$(uname -r)
  if status "$identify_kernel" ; then
    IFS='-'
    read -ra kernel_version <<< "$identify_kernel"
    INFO "Found Kernel version: ${kernel_version}"
    for item in "${IBM_SPECTRUM_SCALE_SUPPORTED_KERNEL[@]}"
    do
      if [[ "$kernel_version" ==  "$item" ]]; then
        kernel_devel_package=(kernel-devel-`uname -r`)
        IBM_SPECTRUM_SCALE_DEPENDENCY_PACKAGES=( "${IBM_SPECTRUM_SCALE_DEPENDENCY_PACKAGES[@]}" "$kernel_devel_package" )
        return 0
      fi
    done
    ERROR "Kernel version is not supported by IBM Spectrum Scale."
    return 1
  else
    ERROR "Unable to identify the Kernel version."
  fi
}
​
function identify_system_package_manager() {
  # This function would identify the System package manager for given instance
  declare -A package_manager;
  package_manager[/etc/redhat-release]=yum
  package_manager[/etc/debian_version]=apt-get
​
  for item in "${!package_manager[@]}"
  do
    if [[ -f $item ]];then
        INFO "Package manager: ${package_manager[$item]}"
        SYSTEM_PACKAGE_MANAGER="${package_manager[$item]}"
        return 0
    fi
  done
  ERROR "Unable to identify System Package Manager."
  return 1
}
​
function valid_package() {
  # This function would validate given package
  if [[ "$SYSTEM_PACKAGE_MANAGER" == "yum" ]]; then
    check_package=$(rpm -qa| grep "$1")
  else
    check_package=$(dpkg -l | grep "$1")
  fi
  if status "$check_package"; then
    return 0
  else
    return 1
  fi
}
​
​
###############################MAIN FUNCTION###############################
echo "This Scripts in intended to validated feasibility of custom AMI for IBM Spectrum Scale deployment on AWS"
​
INFO "1. Validating Operating System"
if valid_os; then
  INFO "Operating System met requirement."
else
  ERROR "List of Operating Systems supported by IBM Spectrum Scale: [ ${IBM_SPECTRUM_SCALE_SUPPORTED_OS[*]} ]"
  exit 1
fi
​
INFO "2. Validating Kernel Version"
if valid_kernel; then
  INFO "Kernel Version met requirement."
else
  ERROR "List of Kernel versions supported by IBM Spectrum Scale: [ ${IBM_SPECTRUM_SCALE_SUPPORTED_KERNEL[*]} ]"
  exit 1
fi
​
INFO "3. Validating Package dependencies for IBM Spectrum Scale"
if identify_system_package_manager; then
  for item in "${IBM_SPECTRUM_SCALE_DEPENDENCY_PACKAGES[@]}"
  do
    if valid_package "$item" ; then
      INFO "Found dependency package: $item"
    else
      WARN "Unable to find dependency package: $item"
    fi
  done
else
  ERROR "Unable to identify package dependency for IBM Spectrum Scale."
  exit 1
fi
​
INFO "4. Checking for existing IBM Spectrum Scale Packages"
if valid_package 'gpfs.base'; then
  WARN "Found exixting IBM Spectrum Scale package"
else
  INFO "No existing package of IBM Spectrum Scale found"
fi
​
echo "This EC2 instance is eligible for IBM Spectrum Scale deployment.
For more details, visit: https://www.ibm.com/support/knowledgecenter/en/STXKQY_AWS_SHR/com.ibm.spectrum.scale.aws.v5r03.doc/bl1cld_aws_kclanding.htm"
