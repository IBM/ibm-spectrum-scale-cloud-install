# Prerequisites

1. You will need to install [*gcloud cli*](https://cloud.google.com/sdk/docs/install) and configure your GCP account using the `gcloud init` command.

2. Create a new service account and select the `Compute Engine Instance Admin (v1)` and `Service Account User` roles.

3. Generate a JSON Key and save it in a secure location.

4. Download the IBM Spectrum Scale Data Management Edition install package (from Fix Central) and upload the GPFS rpm(s) to the GCS bucket.

    Example (Contents of the bucket should look like below for rhel8 Machine Image):

    ```cli
    $ gcloud alpha storage ls gs://spectrumscale_rpms
    gs://spectrumscale_rpms/SpectrumScale_public_key.pgp
    gs://spectrumscale_rpms/gpfs.adv-5.1.4-1.x86_64.rpm
    gs://spectrumscale_rpms/gpfs.afm.cos-1.0.0-6.x86_64.rpm
    gs://spectrumscale_rpms/gpfs.base-5.1.4-1.x86_64.rpm
    gs://spectrumscale_rpms/gpfs.compression-5.1.4-1.x86_64.rpm
    gs://spectrumscale_rpms/gpfs.crypto-5.1.4-1.x86_64.rpm
    gs://spectrumscale_rpms/gpfs.docs-5.1.4-1.noarch.rpm
    gs://spectrumscale_rpms/gpfs.gpl-5.1.4-1.noarch.rpm
    gs://spectrumscale_rpms/gpfs.gskit-8.0.55-19.1.x86_64.rpm
    gs://spectrumscale_rpms/gpfs.gss.pmcollector-5.1.4-1.el8.x86_64.rpm
    gs://spectrumscale_rpms/gpfs.gss.pmsensors-5.1.4-1.el8.x86_64.rpm
    gs://spectrumscale_rpms/gpfs.gui-5.1.4-1.noarch.rpm
    gs://spectrumscale_rpms/gpfs.java-5.1.4-1.x86_64.rpm
    gs://spectrumscale_rpms/gpfs.license.dm-5.1.4-1.x86_64.rpm
    gs://spectrumscale_rpms/gpfs.msg.en_US-5.1.4-1.noarch.rpm
    gs://spectrumscale_rpms/gpfs.nfs-ganesha-3.5-ibm071.16.el8.x86_64.rpm
    gs://spectrumscale_rpms/gpfs.nfs-ganesha-gpfs-3.5-ibm071.16.el8.x86_64.rpm
    gs://spectrumscale_rpms/gpfs.nfs-ganesha-utils-3.5-ibm071.16.el8.x86_64.rpm
    gs://spectrumscale_rpms/gpfs.pm-ganesha-10.0.0-2.el8.x86_64.rpm
    ```

5. Install [Packer binary](https://www.packer.io/downloads) for your operating system.

## Create AWS (packer) AMI

The below steps will provision a GCP VM instance, install IBM Spectrum Scale rpm's and creates a new machine image.

1. Change working directory to `packer_templates/gcp/`.

    ```cli
    cd ibm-spectrum-scale-cloud-install/packer_templates/gcp/
    ```

2. Create packer variable definitions file (`inputs.auto.pkrvars.hcl`) and provide infrastructure inputs.

    Minimal Example:

    ```cli
    cat <<EOF > inputs.auto.pkrvars.hcl
    project_id               = "spectrum-scale-349401"
    image_name               = "spectrumscale"
    gcs_spectrumscale_bucket = "spectrumscale_rpms"
    service_account_json     = "/Users/sasikantheda/Downloads/spectrum-scale-349401-ffce7661e2fc.json"
    EOF
    ```

3. Run `packer init .; packer build .` to create AMI.

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | The size of the volume, in GiB. | `string` | `"200"` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | The volume type. gp2 & gp3 for General Purpose (SSD) volumes. | `string` | `"pd-ssd"` | no |
| <a name="input_gcs_spectrumscale_bucket"></a> [gcs\_spectrumscale\_bucket](#input\_gcs\_spectrumscale\_bucket) | GCS bucket which contains IBM Spectrum Scale rpm(s). | `string` | n/a | yes |
| <a name="input_image_description"></a> [image\_description](#input\_image\_description) | The description to set for the resulting AMI. | `string` | `"IBM Spectrum Scale Image"` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | The name of the resulting image. To make this unique, timestamp will be appended. | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The GCP VM machine type to use while building the image. | `string` | `"n1-standard-2"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project to be used to create the VM/image in your Google Cloud | `string` | n/a | yes |
| <a name="input_service_account_json"></a> [service\_account\_json](#input\_service\_account\_json) | n/a | `string` | `"Service account credential json file path to be used"` | no |
| <a name="input_source_image_family"></a> [source\_image\_family](#input\_source\_image\_family) | The source image family whose root volume will be copied and provisioned on the currently running instance. | `string` | `"rhel-8"` | no |
| <a name="input_user_account"></a> [user\_account](#input\_user\_account) | The username to login/connect to SSH with. | `string` | `"gcpuser"` | no |
| <a name="input_vpc_region"></a> [vpc\_region](#input\_vpc\_region) | The region where GCP operations will take place. Examples are us-central1, us-east1 etc. | `string` | `"us-central1"` | no |
| <a name="input_vpc_zone"></a> [vpc\_zone](#input\_vpc\_zone) | The VPC zone you want to use for building image. | `string` | `"us-central1-a"` | no |

<!-- END_TF_DOCS -->
