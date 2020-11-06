# Generated Documentation 

| Warning: The content under this directory contains auto-generated documentation using [terraform-docs](https://github.com/segmentio/terraform-docs).  Changes made to any files under this directory are not guaranteed to be preserved. |
|---|

## How-To Generate Docs

These instructions will help you generate documentation for template parameters.

1. Download/Install [terraform-docs](https://github.com/segmentio/terraform-docs/releases).

2. Create directories in `docs/gen` using the naming convention of `<cloud_vendor_name>_[new|existing]_<private_network_service_name>`.

    ```
    $ mkdir -p docs/gen/aws_new_vpc          # In case of AWS New Virtual Private Cloud.
    $ mkdir -p docs/gen/aws_existing_vpc     # In case of AWS Existing Virtual Private Cloud.
    ...
    ```

3. Change to the directory of the cloned repo, and run `terraform-docs` to generate the markdown files

   ```
   # Usage:
   ~/terraform-docs markdown <template_path> --hide providers --sort-by-required

   # Example:
   ~/terraform-docs markdown ibm-spectrumscale-cloud-install/aws_scale_templates/aws_new_vpc_scale/ --hide providers --sort-by-required
   ```

4. Copy the documentation to the respective location `docs/gen/<cloud_vendor_name>_[new|existing]_<private_network_service_name>/README.md`.
