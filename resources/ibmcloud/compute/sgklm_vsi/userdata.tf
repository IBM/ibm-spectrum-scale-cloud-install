variable "scale_encryption_admin_password" {}
variable "scale_encryption_admin_default_password" {}
variable "scale_encryption_admin_username" {}
variable "vsi_meta_private_key" {}
variable "vsi_meta_public_key" {}

data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/bin/bash
echo "0 $(hostname) 0" > /home/klmdb411/sqllib/db2nodes.cfg
systemctl start db2c_klmdb411.service
sleep 10
systemctl status db2c_klmdb411.service
sleep 10

#Authenticating using session token
auth_token1=$(curl -k -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d '{"userid":"${var.scale_encryption_admin_username}","password":"${var.scale_encryption_admin_default_password}"}' https://localhost:9443/SKLM/rest/v1/ckms/login)
auth_token=$(echo $auth_token1 | cut -d':' -f 2 | tr -d '}')
curl_command='curl -k -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "Authorization: SKLMAuth userAuthId=sample_auth_token" -H "Accept-Language: en" -d '\''{"type":"selfsigned","alias":"scale","cn":"${var.resource_prefix}-sgklm","ou":"Operation","o":"${var.resource_prefix}","usage":"SSLSERVER","country":"US","validity":"1095","algorithm": "RSA"}'\'' https://localhost:9443/SKLM/rest/v1/certificates'

#Function to reset the Admin Password
function sgklm_passwd_reset {
  pass_reset='curl -X PUT -H "accept: application/json" -H "Accept-Language: en" -H "Content-Type: application/json" -H "Authorization: SKLMAuth userAuthId=sample_auth_token" -d '\''{"password": "${var.scale_encryption_admin_password}"}'\'' https://localhost:9443/SKLM/rest/v1/ckms/usermanagement/users/SKLMAdmin --insecure'
  pass_reset_command=$(echo "$pass_reset" | sed "s/sample_auth_token/$auth_token/")
  eval "$pass_reset_command"
}

#Calling the password reset function
sgklm_passwd_reset

#Copying SSH for passwordless authentication
echo "${var.vsi_meta_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.vsi_meta_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
reboot
EOF
}
