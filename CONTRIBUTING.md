# Contributing

When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.

## Pull Request Process

1. Fork the repo, create a branch for your feature
2. Follow [terraform coding practices](#coding-practices)
3. Install [pre-commit hook dependencies](#install-precommit-hooks)
4. [Sign your work](#sign-your-work-for-submittal)
5. [Sync Your Fork](#sync-your-fork)
6. Create a Pull Request for your feature

### Coding Practices

1. Terraform version
   - All code should support the latest version of the latest Terraform GA release.
2. Variables, Looping, Outputs
   - Static values shouldn't be hardcoded inside the Terraform configuration, static values should be defined as Terraform variables, this extends the flexibility of the Terraform nodules for future use.
   - Optional variables for resources should still be included (where sensible) to ensure future extendability of the module.
   - Wherever possible we recommend marking your input variable and/or output value declarations as sensitive.
   - `for_each` looping should be used instead of `count` when multiple resources need to be created. This results in a resource `map` instead of `list` when the created resources are added to the Terraform state tree which allows you to remove an object from Terraform state despite the position of the object where it is inserted.
   - `count` should only be used when creating a single resource with a conditional statement. For an example you may decide to create a resource based on an existence of an input variable.
   - Add Terraform output values and description, which allows you to export structured data about your resources.
3. Terraform Module Structure
    - We will maintain one directory per cloud provider (Four directories, representing AWS, Azure, GCP, and IBM Cloud). Where each cloud vendor directory structure looks like below;

    ```bash
    |── aws_scale_templates/
    │   ├── aws_new_vpc_scale/        <- Templates corresponding to new vpc.
    │   │   │   ├── variables.tf
    │   │   │   ├── main.tf
    │   │   │   ├── outputs.tf
    │   │   │   ├── versions.tf
    │   │   │   ├── README.md
    │   │   │   ├── .terraform-docs.yml
    │   ├── prepare_tf_s3_backend/
    │   │   │   ├── variables.tf
    │   │   │   ├── main.tf
    │   │   │   ├── outputs.tf
    │   │   │   ├── versions.tf
    │   │   │   ├── README.md
    │   │   │   ├── .terraform-docs.yml
    │   ├── sub_modules/
    │   │   ├── vpc_template/
    │   │   │   ├── variables.tf
    │   │   │   ├── main.tf
    │   │   │   ├── outputs.tf
    │   │   │   ├── versions.tf
    │   │   │   ├── README.md
    │   │   │   ├── .terraform-docs.yml
    │   │   ├── bastion_template/
    │   │   │   ├── variables.tf
    │   │   │   ├── main.tf
    │   │   │   ├── outputs.tf
    │   │   │   ├── versions.tf
    │   │   │   ├── README.md
    │   │   │   ├── .terraform-docs.yml
    │   │   ├── instance_template/     <- Templates corresponding to existing vpc.
    │   │   │   ├── variables.tf
    │   │   │   ├── main.tf
    │   │   │   ├── outputs.tf
    │   │   │   ├── versions.tf
    │   │   │   ├── README.md
    │   │   │   ├── .terraform-docs.yml
    ```

4. Terraform unit test Structure
    - We will maintain one unit test directory per cloud provider (Four directories, representing AWS, Azure, GCP, and IBM Cloud) and found in `unittests/`.

### Install precommit hooks

1. Install dependencies

   ```bash
   # pip3 install pre-commit
   # curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz && tar xzf terraform-docs.tgz && chmod +x terraform-docs && sudo mv terraform-docs /usr/bin/
   # curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && sudo mv tflint /usr/bin/
   # curl -L "$(curl -s https://api.github.com/repos/tfsec/tfsec/releases/latest | grep -o -E "https://.+?tfsec-linux-amd64")" > tfsec && chmod +x tfsec && sudo mv tfsec /usr/bin/
   ```

2. Enable pre-commit hooks

   ```bash
   # cd ibm-spectrum-scale-cloud-install
   # ./tools/setup_dev_env.sh
   ```

### Sync Your Fork

Before submitting a pull request, make sure your fork is up to date with the latest upstream changes.

```bash
git fetch upstream
git checkout master
git merge upstream/master
```

### Sign your work for submittal

The sign-off is a simple line at the end of the explanation for the patch. Your signature certifies that you wrote the patch or otherwise have the right to pass it on as an open-source patch. You just add a line to every git commit message:

Signed-off-by: Joe Smith <joe.smith@email.com>
Use your real name (sorry, no pseudonyms or anonymous contributions.)

If you set your user.name and user.email git configs, you can sign your commit automatically with git commit -s.
