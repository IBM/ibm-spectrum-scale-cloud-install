#!/bin/bash
set -ex

sleep 30
if [ -f /etc/os-release ] && grep -qiE 'Ubuntu' /etc/os-release; then
    sudo rm -rf /var/log/ubuntu-advantage.log
    sudo cloud-init clean --machine-id
elif [ -f /etc/os-release ] && grep -qiE 'redhat' /etc/os-release; then
    # Resize the root from default 2Gi
    sudo lvextend -r -l +100%FREE /dev/mapper/rootvg-rootlv
    sudo dnf clean all
    sudo dnf makecache
    sudo dnf install -y unzip python3 python3-pip jq numactl
    sudo dnf install -y kernel-devel-`uname -r` kernel-headers-`uname -r`
    sudo dnf install -y make gcc-c++ elfutils-libelf-devel bind-utils nftables iptables nvme-cli
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    if sudo grep -q el8 /etc/os-release; then
        sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
    elif sudo grep -q el9 /etc/os-release; then
        sudo dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
    fi
    sudo dnf install -y azure-cli
    sudo sh -c "echo '[IBMScaleRepository]' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'name=IBM Storage Scale Repository' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'baseurl=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/gpfs_rpms/' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'enabled=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgkey=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo -e '\n' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo '[IBMScaleAPIRepository]' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'name=IBM Storage Scale API Repository' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'baseurl=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/scaleapi_rpms/' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'enabled=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgkey=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo -e '\n' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo '[Kakfa]' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'name=IBM Storage Scale Kakfa Repository' >> /etc/yum.repos.d/scale.repo"
    if sudo grep -q el8 /etc/os-release; then
       sudo sh -c "echo 'baseurl=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/gpfs_rpms/rhel8/' >> /etc/yum.repos.d/scale.repo"
    elif sudo grep -q el9 /etc/os-release; then
       sudo sh -c "echo 'baseurl=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/gpfs_rpms/rhel9/' >> /etc/yum.repos.d/scale.repo"
    fi
    sudo sh -c "echo 'enabled=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgkey=http://$PACKAGE_REPOSITORY.s3-website.$VPC_REGION.amazonaws.com/$SCALE_VERSION/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo -e '\n' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo '[ZimonRepository]' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'name=IBM Storage Scale Zimon Repository' >> /etc/yum.repos.d/scale.repo"
    if sudo grep -q el8 /etc/os-release; then
        sudo sh -c "echo 'baseurl=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/zimon_rpms/rhel8/' >> /etc/yum.repos.d/scale.repo"
    elif sudo grep -q el9 /etc/os-release; then
        sudo sh -c "echo 'baseurl=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/zimon_rpms/rhel9/' >> /etc/yum.repos.d/scale.repo"
    fi
    sudo sh -c "echo 'enabled=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgkey=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo -e '\n' >> /etc/yum.repos.d/scale.repo"
    sudo dnf install -y gpfs.base gpfs.docs gpfs.msg.en* gpfs.compression gpfs.ext gpfs.gpl gpfs.gskit gpfs.gui gpfs.java gpfs.gss.pmcollector gpfs.gss.pmsensors gpfs.afm.cos gpfs.compression gpfs.license* gpfs.librdkafka* gpfs.scaleapi*
    if sudo dnf search gpfs.adv | grep -q "gpfs.adv"; then
        sudo dnf install -y gpfs.adv
    fi
    if sudo dnf search gpfs.crypto | grep -q "gpfs.crypto"; then
        sudo dnf install -y gpfs.crypto
    fi
fi

ces_failover() {
    sudo cp /usr/lpp/mmfs/samples/cloud/ces_middleware/mmcesExtendedIpMgmt.azure /var/mmfs/etc/mmcesExtendedIpMgmt
}

install_nfs() {
    sudo sh -c "echo '[NFSProtocolRepository]' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'name=IBM Storage Scale NFS Protocol Repository' >> /etc/yum.repos.d/scale.repo"
    if sudo grep -q el8 /etc/os-release; then
        sudo sh -c "echo 'baseurl=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/ganesha_rpms/rhel8/' >> /etc/yum.repos.d/scale.repo"
    elif sudo grep -q el9 /etc/os-release; then
        sudo sh -c "echo 'baseurl=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/ganesha_rpms/rhel9/' >> /etc/yum.repos.d/scale.repo"
    fi
    sudo sh -c "echo 'enabled=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgkey=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo -e '\n' >> /etc/yum.repos.d/scale.repo"
    sudo dnf install -y gpfs.nfs-ganesha gpfs.nfs-ganesha-gpfs gpfs.nfs-ganesha-utils
    sudo dnf install -y gpfs.pm-ganesha
}

install_smb() {
    sudo sh -c "echo '[SMBProtocolRepository]' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'name=IBM Storage Scale SMB Protocol Repository' >> /etc/yum.repos.d/scale.repo"
    if sudo grep -q el8 /etc/os-release; then
        sudo sh -c "echo 'baseurl=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/smb_rpms/rhel8/' >> /etc/yum.repos.d/scale.repo"
    elif sudo grep -q el9 /etc/os-release; then
        sudo sh -c "echo 'baseurl=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/smb_rpms/rhel9/' >> /etc/yum.repos.d/scale.repo"
    fi
    sudo sh -c "echo 'enabled=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgkey=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo -e '\n' >> /etc/yum.repos.d/scale.repo"
    sudo dnf install -y gpfs.smb
}

install_s3() {
    sudo sh -c "echo '[S3ProtocolRepository]' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'name=IBM Storage Scale S3 Protocol Repository' >> /etc/yum.repos.d/scale.repo"
    if sudo grep -q el8 /etc/os-release; then
        sudo sh -c "echo 'baseurl=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/s3_rpms/rhel8/' >> /etc/yum.repos.d/scale.repo"
    elif sudo grep -q el9 /etc/os-release; then
        sudo sh -c "echo 'baseurl=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/s3_rpms/rhel9/' >> /etc/yum.repos.d/scale.repo"
    fi
    sudo sh -c "echo 'enabled=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgkey=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo -e '\n' >> /etc/yum.repos.d/scale.repo"
    sudo dnf install -y gpfs.mms3 noobaa-core
}

install_hdfs() {
    sudo sh -c "echo '[HDFSProtocolRepository]' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'name=IBM Storage Scale HDFS Protocol Repository' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'baseurl=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/hdfs_rpms/rhel/hdfs_3.3.6.x' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'enabled=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo 'gpgkey=$STORAGE_ACCOUNT_URL/$SCALE_VERSION/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo"
    sudo sh -c "echo -e '\n' >> /etc/yum.repos.d/scale.repo"
    sudo dnf install -y gpfs.hdfs-protocol
}

case "$INSTALL_PROTOCOLS" in
    None)
        echo "skipping protocol rpm installation"
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
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo rm -rf /etc/yum.repos.d/scale.repo
sudo dnf clean all
sudo rm -rf /var/cache/dnf
sudo rm -rf /root/.ssh/authorized_keys
sudo rm -rf /home/$SSH_USERNAME/authorized_keys
sudo rm -rf /root/.bash_history
sudo rm -rf /home/$SSH_USERNAME/.bash_history
sudo /usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync
