/*
    Creates specified number of IBM Cloud Virtual Server Instance(s).
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "key_protect_instance_id" {}
variable "resource_prefix" {}
variable "vpc_region" {}
variable "resource_group_id" {}
variable "key_protect_path" {}
variable "resource_tags" {}
variable "vpc_storage_cluster_dns_domain" {}

resource "null_resource" "openssl_commands" {
  provisioner "local-exec" {
    command = <<EOT
      # Create a Key_Protect folder if not exists
      mkdir -p "${var.key_protect_path}"
      # Get the Key Protect Server certificate
      openssl s_client -showcerts -connect "${var.vpc_region}.kms.cloud.ibm.com:5696" < /dev/null > "${var.key_protect_path}/Key_Protect_Server.cert"
      # Extract the end date of the certificate
      [ -f "${var.key_protect_path}/Key_Protect_Server.cert" ] &&  END_DATE=$(openssl x509 -enddate -noout -in "${var.key_protect_path}/Key_Protect_Server.cert" | awk -F'=' '{print $2}')
      # Get the current date in GMT
      CURRENT_DATE=$(date -u +"%b %d %T %Y %Z")
      # Calculate the difference in days
      DIFF_DAYS=$(echo $(( ( $(date -ud "$END_DATE" +%s) - $(date -ud "$CURRENT_DATE" +%s) ) / 86400 )))
      # Create a Key Protect Server Root and CA certs
      [ -f "${var.key_protect_path}/Key_Protect_Server.cert" ] && awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' "${var.key_protect_path}/Key_Protect_Server.cert" > "${var.key_protect_path}/Key_Protect_Server_CA.cert"
      [ -f "${var.key_protect_path}/Key_Protect_Server_CA.cert" ] && awk '/-----BEGIN CERTIFICATE-----/{x="${var.key_protect_path}/Key_Protect_Server.chain"i".cert"; i++} {print > x}' "${var.key_protect_path}/Key_Protect_Server_CA.cert"
      [ -f "${var.key_protect_path}/Key_Protect_Server.chain.cert" ] && mv "${var.key_protect_path}/Key_Protect_Server.chain.cert" "${var.key_protect_path}/Key_Protect_Server.chain0.cert"
      # Create a Self Signed Certificates
      [ ! -f "${var.key_protect_path}/${var.resource_prefix}.key" ] && openssl genpkey -algorithm RSA -out "${var.key_protect_path}/${var.resource_prefix}.key"
      [ ! -f "${var.key_protect_path}/${var.resource_prefix}.csr" ] && openssl req -new -key "${var.key_protect_path}/${var.resource_prefix}.key" -out "${var.key_protect_path}/${var.resource_prefix}.csr" -subj "/CN=${var.vpc_storage_cluster_dns_domain}"
      [ ! -f "${var.key_protect_path}/${var.resource_prefix}.cert" ] && openssl x509 -req -days $DIFF_DAYS -in "${var.key_protect_path}/${var.resource_prefix}.csr" -signkey "${var.key_protect_path}/${var.resource_prefix}.key" -out "${var.key_protect_path}/${var.resource_prefix}.cert"
    EOT
  }
}

data "local_file" "kpclient_cert" {
  depends_on = [null_resource.openssl_commands]
  filename   = "${var.key_protect_path}/${var.resource_prefix}.cert"
}

resource "ibm_resource_instance" "kms_instance" {
  count             = var.key_protect_instance_id == null ? 1 : 0
  name              = format("%s-kp", var.resource_prefix)
  service           = "kms"
  plan              = "tiered-pricing"
  location          = var.vpc_region
  resource_group_id = var.resource_group_id
  tags              = var.resource_tags
}

resource "ibm_kms_key" "key" {
  instance_id  = var.key_protect_instance_id == null ? ibm_resource_instance.kms_instance[0].guid : var.key_protect_instance_id
  key_name     = "key"
  standard_key = false
}

resource "ibm_kms_kmip_adapter" "myadapter" {
  instance_id = var.key_protect_instance_id == null ? ibm_resource_instance.kms_instance[0].guid : var.key_protect_instance_id
  profile     = "native_1.0"
  profile_data = {
    "crk_id" = ibm_kms_key.key.key_id
  }
  description = "Key Protect adapter"
  name        = format("%s-kp-adapter", var.resource_prefix)
}

resource "ibm_kms_kmip_client_cert" "mycert" {
  instance_id = var.key_protect_instance_id == null ? ibm_resource_instance.kms_instance[0].guid : var.key_protect_instance_id
  adapter_id  = ibm_kms_kmip_adapter.myadapter.adapter_id
  certificate = data.local_file.kpclient_cert.content
  name        = format("%s-kp-cert", var.resource_prefix)
  depends_on  = [data.local_file.kpclient_cert]
}
