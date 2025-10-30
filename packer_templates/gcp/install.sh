#!/bin/bash
set -ex

sleep 30
if [ -f /etc/os-release ] && grep -qiE 'redhat' /etc/os-release; then
    sudo dnf makecache
    sudo dnf install -y kernel-devel-`uname -r` kernel-headers-`uname -r`
    sudo dnf install -y make gcc-c++ elfutils-libelf-devel numactl
    sudo sh -c "echo '[ar-plugin]' >> /etc/yum.repos.d/artifact-registry-plugin.repo"
    sudo sh -c "echo 'name=Artifact Registry Plugin' >> /etc/yum.repos.d/artifact-registry-plugin.repo"
    sudo sh -c "echo 'baseurl=https://packages.cloud.google.com/yum/repos/dnf-plugin-artifact-registry-stable' >> /etc/yum.repos.d/artifact-registry-plugin.repo"
    sudo sh -c "echo 'enabled=1' >> /etc/yum.repos.d/artifact-registry-plugin.repo"
    sudo sh -c "echo 'gpgcheck=1' >> /etc/yum.repos.d/artifact-registry-plugin.repo"
    sudo sh -c "echo 'repo_gpgcheck=0' >> /etc/yum.repos.d/artifact-registry-plugin.repo"
    sudo sh -c "echo 'gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg' >> /etc/yum.repos.d/artifact-registry-plugin.repo"
    sudo dnf install -y dnf-plugin-artifact-registry
    sudo mkdir -p /root/.ssh/
    sudo sh -c "echo 'StrictHostKeyChecking no' >> ~/.ssh/config"
    sudo sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
    sudo sh -c "echo '[IBMScaleRepository]' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'name=IBM Storage Scale Repository' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'baseurl=https://$VPC_REGION-yum.pkg.dev/projects/$PROJECT_ID/$ARTIFACT_ID' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'enabled=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'repo_gpgcheck=0' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgcheck=0' >> /etc/yum.repos.d/scale.repo"
    sudo dnf install -y gpfs.base gpfs.docs gpfs.msg.en* gpfs.compression gpfs.ext gpfs.gpl gpfs.gskit gpfs.gui gpfs.java gpfs.gss.pmcollector gpfs.gss.pmsensors gpfs.afm.cos gpfs.compression gpfs.license* gpfs.scaleapi*
    if sudo dnf search gpfs.adv | grep -q "gpfs.adv"; then
        sudo dnf install -y gpfs.adv
    fi
    if sudo dnf search gpfs.crypto | grep -q "gpfs.crypto"; then
        sudo dnf install -y gpfs.crypto
    fi
    # gpfs.librdkafka rpm depends on libcrypto.so.3 which is available on RHEL9 and not on RHEL8
    if sudo grep -q el9 /etc/os-release; then
        sudo dnf install -y gpfs.librdkafka-*.el9.*
    fi
fi

ces_failover() {
    sudo cp /usr/lpp/mmfs/samples/cloud/ces_middleware/mmcesExtendedIpMgmt.gcp /var/mmfs/etc/mmcesExtendedIpMgmt
}

install_nfs() {
    sudo dnf install -y gpfs.nfs-ganesha gpfs.nfs-ganesha-gpfs gpfs.nfs-ganesha-utils
    sudo dnf install -y gpfs.pm-ganesha
}

install_smb() {
    sudo dnf install -y gpfs.smb
}

install_s3() {
    sudo dnf install -y gpfs.mms3 noobaa-core
}

install_hdfs() {
    sudo dnf install -y gpfs.hdfs-protocol
}

case "$INSTALL_PROTOCOLS" in
    None)
        echo "skipping protocol rpm/debs installation"
        ;;
    nfs)
        ces_failover
        install_nfs
        ;;
    smb)
        ces_failover
        install_smb
        ;;
    s3)
        ces_failover
        install_s3
        ;;
    hdfs)
	ces_failover
	install_hdfs
	;;
    nfs-s3)
        ces_failover
        install_nfs
        install_s3
        ;;
    nfs-smb)
        ces_failover
        install_nfs
        install_smb
        ;;
    smb-s3)
        ces_failover
        install_smb
        install_s3
        ;;
    nfs-hdfs)
       ces_failover
       install_nfs
       install_hdfs
       ;;
    smb-hdfs)
	ces_failover
	install_smb
	install_hdfs
	;;
    s3-hdfs)
	ces_failover
	install_s3
	install_hdfs
	;;
    *)
        ces_failover
        install_nfs
        install_smb
        install_s3
	install_hdfs
        ;;
esac

sudo /usr/lpp/mmfs/bin/mmbuildgpl
sudo sh -c "echo 'export PATH=$PATH:$HOME/bin:/usr/lpp/mmfs/bin' >> /root/.bashrc"
if [ -f /etc/os-release ] && grep -qiE 'Ubuntu' /etc/os-release; then
    sudo rm -rf /etc/apt/sources.list.d/scale.list
    sudo apt-get clean
    sudo ua detach --assume-yes
    sudo rm -rf /var/log/ubuntu-advantage.log
    sudo cloud-init clean --machine-id
elif [ -f /etc/os-release ] && grep -qiE 'redhat' /etc/os-release; then
    sudo rm -rf /etc/yum.repos.d/scale.repo
    sudo dnf clean all
    sudo rm -rf /var/cache/dnf
    sudo rm -rf /root/.bash_history
    sudo rm -rf /home/$SSH_USERNAME/.bash_history
fi
