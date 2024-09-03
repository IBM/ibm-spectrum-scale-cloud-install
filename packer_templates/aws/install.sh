#!/bin/bash
set -ex

sleep 30
if [ -f /etc/os-release ] && grep -qiE 'Ubuntu' /etc/os-release; then
    echo "debconf debconf/frontend select Noninteractive" | sudo debconf-set-selections
    sudo apt-get -y install make cpp gcc g++
    sudo apt-get -y install unzip
    sudo curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
    sudo unzip awscliv2.zip
    sudo ./aws/install
    sudo rm -rf awscliv2.zip
    curl -sS http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/Public_Keys/Storage_Scale_public_key.pgp | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/scale.gpg
    sudo sh -c "echo 'deb [trusted=yes] http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/gpfs_debs /' >> /etc/apt/sources.list.d/scale.list"
    if sudo grep -q jammy /etc/os-release; then
        sudo sh -c "echo 'deb [trusted=yes] http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/zimon_debs/ubuntu/ubuntu22 /' >> /etc/apt/sources.list.d/scale.list"
    fi
    sudo apt-get update
    sudo apt-get -y install gpfs.base gpfs.docs gpfs.msg.en-us gpfs.compression gpfs.gpl gpfs.gskit gpfs.gui gpfs.java gpfs.afm.cos gpfs.license* gpfs.gss.pmcollector gpfs.gss.pmsensors
    if sudo apt-cache search gpfs.adv | grep -q "gpfs.adv"; then
        sudo apt-get -y install gpfs.adv
    fi
    if sudo apt-cache search gpfs.crypto | grep -q "gpfs.crypto"; then
        sudo apt-get -y install gpfs.crypto
    fi
elif [ -f /etc/os-release ] && grep -qiE 'redhat' /etc/os-release; then
    sudo dnf install -y unzip python3 python3-pip jq numactl
    sudo dnf install -y kernel-devel-`uname -r` kernel-headers-`uname -r`
    sudo dnf install -y make gcc-c++ elfutils-libelf-devel bind-utils nftables iptables nvme-cli
    sudo dnf install -y sssd-tools sssd openldap-clients
    sudo curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
    sudo unzip awscliv2.zip
    sudo ./aws/install
    sudo rm -rf awscliv2.zip
    sudo sh -c "echo '[IBMScaleRepository]' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'name=IBM Storage Scale Repository' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'baseurl=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/gpfs_rpms/' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'enabled=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgkey=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo -e '\n' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo '[ZimonRepository]' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'name=IBM Storage Scale Zimon Repository' >> /etc/yum.repos.d/scale.repo"
    if sudo grep -q el8 /etc/os-release; then
        sudo sh -c "echo 'baseurl=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/zimon_rpms/rhel8/' >> /etc/yum.repos.d/scale.repo"
    elif sudo grep -q el9 /etc/os-release; then
        sudo sh -c "echo 'baseurl=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/zimon_rpms/rhel9/' >> /etc/yum.repos.d/scale.repo"
    fi
    sudo sh -c "echo 'enabled=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgkey=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo -e '\n' >> /etc/yum.repos.d/scale.repo"
    sudo dnf install -y gpfs.base gpfs.docs gpfs.msg.en* gpfs.compression gpfs.ext gpfs.gpl gpfs.gskit gpfs.gui gpfs.java gpfs.gss.pmcollector gpfs.gss.pmsensors gpfs.afm.cos gpfs.compression gpfs.license*
    if sudo dnf search gpfs.adv | grep -q "gpfs.adv"; then
        sudo dnf install -y gpfs.adv
    fi
    if sudo dnf search gpfs.crypto | grep -q "gpfs.crypto"; then
        sudo dnf install -y gpfs.crypto
    fi
fi

ces_failback() {
    sudo cp /usr/lpp/mmfs/samples/cloud/ces_middleware/mmcesExtendedIpMgmt.aws /var/mmfs/etc/mmcesExtendedIpMgmt
}

install_nfs() {
    if [ -f /etc/os-release ] && grep -qiE 'Ubuntu' /etc/os-release; then
        if sudo grep -q jammy /etc/os-release; then
            sudo sh -c "echo 'deb [trusted=yes] http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/ganesha_debs/ubuntu/ubuntu22 /' >> /etc/apt/sources.list.d/scale.list"
        fi
        sudo apt-get update
        sudo apt-get -y install gpfs.nfs-ganesha gpfs.nfs-ganesha-gpfs gpfs.nfs-ganesha-utils
    elif [ -f /etc/os-release ] && grep -qiE 'redhat' /etc/os-release; then
        sudo sh -c "echo '[NFSProtocolRepository]' >> /etc/yum.repos.d/scale.repo"
        sudo sh -c "echo 'name=IBM Storage Scale NFS Protocol Repository' >> /etc/yum.repos.d/scale.repo"
        if sudo grep -q el8 /etc/os-release; then
            sudo sh -c "echo 'baseurl=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/ganesha_rpms/rhel8/' >> /etc/yum.repos.d/scale.repo"
        elif sudo grep -q el9 /etc/os-release; then
            sudo sh -c "echo 'baseurl=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/ganesha_rpms/rhel9/' >> /etc/yum.repos.d/scale.repo"
        fi
        sudo sh -c "echo 'enabled=1' >> /etc/yum.repos.d/scale.repo"
        sudo sh -c "echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo"
        sudo sh -c "echo 'gpgkey=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo"
        sudo sh -c "echo -e '\n' >> /etc/yum.repos.d/scale.repo"
        sudo dnf install -y gpfs.nfs-ganesha gpfs.nfs-ganesha-gpfs gpfs.nfs-ganesha-utils
        sudo dnf install -y gpfs.pm-ganesha
    fi
}

install_smb() {
    if [ -f /etc/os-release ] && grep -qiE 'Ubuntu' /etc/os-release; then
        if sudo grep -q jammy /etc/os-release; then
            sudo sh -c "echo 'deb [trusted=yes] http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/smb_debs/ubuntu/ubuntu22 /' >> /etc/apt/sources.list.d/scale.list"
        fi
        sudo apt-get update
        sudo apt-get -y install gpfs.nfs-ganesha gpfs.nfs-ganesha-gpfs gpfs.nfs-ganesha-utils
    elif [ -f /etc/os-release ] && grep -qiE 'redhat' /etc/os-release; then
        sudo sh -c "echo '[SMBProtocolRepository]' >> /etc/yum.repos.d/scale.repo"
        sudo sh -c "echo 'name=IBM Storage Scale SMB Protocol Repository' >> /etc/yum.repos.d/scale.repo"
        if sudo grep -q el8 /etc/os-release; then
            sudo sh -c "echo 'baseurl=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/smb_rpms/rhel8/' >> /etc/yum.repos.d/scale.repo"
        elif sudo grep -q el9 /etc/os-release; then
            sudo sh -c "echo 'baseurl=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/smb_rpms/rhel9/' >> /etc/yum.repos.d/scale.repo"
        fi
        sudo sh -c "echo 'enabled=1' >> /etc/yum.repos.d/scale.repo"
        sudo sh -c "echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo"
        sudo sh -c "echo 'gpgkey=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo"
        sudo sh -c "echo -e '\n' >> /etc/yum.repos.d/scale.repo"
        sudo dnf install -y gpfs.smb
    fi
}

install_s3() {
    if [ -f /etc/os-release ] && grep -qiE 'redhat' /etc/os-release; then
        sudo sh -c "echo '[S3ProtocolRepository]' >> /etc/yum.repos.d/scale.repo"
        sudo sh -c "echo 'name=IBM Storage Scale S3 Protocol Repository' >> /etc/yum.repos.d/scale.repo"
        if sudo grep -q el8 /etc/os-release; then
            sudo sh -c "echo 'baseurl=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/s3_rpms/rhel8/' >> /etc/yum.repos.d/scale.repo"
        elif sudo grep -q el9 /etc/os-release; then
            sudo sh -c "echo 'baseurl=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/s3_rpms/rhel9/' >> /etc/yum.repos.d/scale.repo"
        fi
        sudo sh -c "echo 'enabled=1' >> /etc/yum.repos.d/scale.repo"
        sudo sh -c "echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo"
        sudo sh -c "echo 'gpgkey=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo"
        sudo sh -c "echo -e '\n' >> /etc/yum.repos.d/scale.repo"
        sudo dnf install -y gpfs.mms3 noobaa-core
    fi
}

case "$INSTALL_PROTOCOLS" in
    None)
        echo "skipping protocol rpm/debs installation"
        ;;
    nfs)
        ces_failback
        install_nfs
        ;;
    smb)
        ces_failback
        install_smb
        ;;
    s3)
        ces_failback
        install_s3
        ;;
    nfs-s3)
        ces_failback
        install_nfs
        install_s3
        ;;
    nfs-smb)
        ces_failback
        install_nfs
        install_smb
        ;;
    smb-s3)
        ces_failback
        install_smb
        install_s3
        ;;
    *)
        ces_failback
        install_nfs
        install_smb
        install_s3
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
    sudo rm -rf /home/ec2-user/.bash_history
fi
