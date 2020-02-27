## Auto-Generate Docs for Template Parameters

These instructions will help you generate documentation for template parameters.

1. Clone `ibm-spectrum-scale-cloud-install` repository to your on-premise machine.
   
    ```
    $ git clone https://github.com/IBM/ibm-spectrum-scale-cloud-install.git
    ```

2. Install the latest release of [terraform-docs](https://github.com/segmentio/terraform-docs/releases).

3. Create directories in `docs/` using the naming convention of `<cloud_vendor_name>_[new|existing]_<private_network_service_name>`.

    ```
    $ mkdir docs/aws_new_vpc          # In case of AWS New Virtual Private Cloud.
    $ mkdir docs/aws_existing_vpc     # In case of AWS Existing Virtual Private Cloud.
    ```

4. Generate documentation from terraform templates using following command;

   ```
   $ ./terraform-docs markdown <template_path> --no-providers --sort-by-required
   ```
   ```
   Ex: ./terraform-docs markdown ibm-spectrumscale-cloud-install/aws_scale_templates/aws_new_vpc_scale/ --no-providers --sort-by-required 
   ```

5. Verify the generated template parameters documentation.

6. Copy the documentation to the respective location `docs/<cloud_vendor_name>_[new|existing]_<private_network_service_name>/README.md`.

7. Update the [Template Parameters](https://github.com/IBM/ibm-spectrum-scale-cloud-install/README.md#Template-Parameters) with links of generated content.
