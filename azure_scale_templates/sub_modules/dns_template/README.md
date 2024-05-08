# Configure Azure Private DNS and associate with a VNet

The below steps will provision the Azure private DNS zones required for the IBM Spectrum Scale cloud solution.

1. Change the working directory to `azure_scale_templates/sub_modules/dns_template`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/azure_scale_templates/sub_modules/dns_template/
    ```

2. Create terraform variable definitions file (`terraform.tfvars.json`) and provide infrastructure inputs.

    Minimal Example-1:

    ```cli
    cat <<EOF > combined_1az.auto.tfvars.json
    {
	    "client_id": "xxxx1ee24-5f02-4066-b3b7-xxxxxxxxxx",
	    "client_secret": xxxxxxwiywnrm.FaqwZxxxxxxxxxxxx",
        "subscription_id": "xxx3cd6f-667b-4a89-a046-dexxxxxxxx",
        "tenant_id": "xxxx057-50c9-4ad4-98f3-xxxxxx",
	    "cluster_type": "Combined-compute-storage",
	    "create_dns_zone": true,
	    "resource_group_name": "spectrum-scale-rg",
	    "resource_prefix": "ibm-storage-scale",
	    "vpc_compute_cluster_dns_zone": "ibm-storage-scale.compscale.com",
	    "vpc_region": "southcentralus",
	    "vpc_reverse_dns_zone": "10.in-addr.arpa",
	    "vpc_storage_cluster_dns_zone": "ibm-storage-scale.strgscale.com",
	    "vpc_ref": "/subscriptions/xxx3cd6f-667b-4a89-a046-dexxxxxxxx/resourceGroups/spectrum-scale-rg/providers/Microsoft.Network/virtualNetworks/ibm-storage-scale"
    }
    EOF
    ```

3. Run `terraform init` and `terraform apply -auto-approve` to provision resources.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | ~> 3.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_client_id"></a> [client_id](#input_client_id) | The Active Directory service principal associated with your account. | `string` |
| <a name="input_client_secret"></a> [client_secret](#input_client_secret) | The password or secret for your service principal. | `string` |
| <a name="input_cluster_type"></a> [cluster_type](#input_cluster_type) | Cluster type to provision. Examples: Storage-only, Compute-only, Combined-compute-storage. | `string` |
| <a name="input_create_dns_zone"></a> [create_dns_zone](#input_create_dns_zone) | Flag to represent if a new private DNS zone needs to be created or reused. | `bool` |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | The name of a new resource group in which the resources will be created. | `string` |
| <a name="input_subscription_id"></a> [subscription_id](#input_subscription_id) | The subscription ID to use. | `string` |
| <a name="input_tenant_id"></a> [tenant_id](#input_tenant_id) | The Active Directory tenant identifier, must provide when using service principals. | `string` |
| <a name="input_vpc_compute_cluster_dns_zone"></a> [vpc_compute_cluster_dns_zone](#input_vpc_compute_cluster_dns_zone) | Route53 DNS zone name/id (incase of new creation use name, incase of association use id). | `string` |
| <a name="input_vpc_ref"></a> [vpc_ref](#input_vpc_ref) | VNet id to be associated with the DNS zone (Ex: /subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/virtualNetworks/virtualNetworksValue). | `string` |
| <a name="input_vpc_reverse_dns_zone"></a> [vpc_reverse_dns_zone](#input_vpc_reverse_dns_zone) | Private DNS zone name. | `string` |
| <a name="input_vpc_storage_cluster_dns_zone"></a> [vpc_storage_cluster_dns_zone](#input_vpc_storage_cluster_dns_zone) | Private DNS zone name. | `string` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_compute_cluster_dns_zone"></a> [vpc_compute_cluster_dns_zone](#output_vpc_compute_cluster_dns_zone) | Private DNS zone name/id. |
| <a name="output_vpc_compute_dns_zone_id"></a> [vpc_compute_dns_zone_id](#output_vpc_compute_dns_zone_id) | Private DNS zone id. |
| <a name="output_vpc_reverse_dns_zone"></a> [vpc_reverse_dns_zone](#output_vpc_reverse_dns_zone) | Private DNS zone name/id. |
| <a name="output_vpc_reverse_dns_zone_id"></a> [vpc_reverse_dns_zone_id](#output_vpc_reverse_dns_zone_id) | Private DNS zone id. |
| <a name="output_vpc_storage_cluster_dns_zone"></a> [vpc_storage_cluster_dns_zone](#output_vpc_storage_cluster_dns_zone) | Private DNS zone name/id. |
| <a name="output_vpc_storage_dns_zone_id"></a> [vpc_storage_dns_zone_id](#output_vpc_storage_dns_zone_id) | Private DNS zone id. |
<!-- END_TF_DOCS -->
