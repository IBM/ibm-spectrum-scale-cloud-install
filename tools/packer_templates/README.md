## AWS-Spectrum Scale Packer Usage

```
packer build -var aws_access_key=<YOUR_ACCESS_KEY> \
             -var aws_secret_key=<YOUR_SECRET_KEY> \
             -var aws_region=<AWS_REGION> \
             -var aws_instance_type="t2.medium" \
             -var aws_source_ami=<SOURCE_AMI_ID> \
             -var aws_ami_name="Scale-Image" \
             -var s3_spectrumscale_bucket=<SPECTRUMSCALE_RPM_REPO> aws_ami_packer.json
```