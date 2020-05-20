# Cloud Install 

This repository contains Terraform templates to provision public cloud infrastructure (i.e. AWS, Azure) where IBM Spectrum Scale can then be installed. 

## Prerequisites

Ensure that the following requirements are met on the server where this repository is cloned. 

* Install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) and validate:

    * `terraform -v`

* Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) and validate: 

    * `ansible --version` 

## Usage

  * [Amazon Web Services (AWS)](docs/aws.md)
  * [Microsoft Azure (Azure)](docs/azure.md)
  * [Google Cloud Platform (GCP)](docs/gcp.md)


### Reporting Issues and Feedback

To file issues, suggestions, new features, etc., please open an [Issue](https://github.com/IBM/ibm-spectrum-scale-cloud-install/issues).

### Disclaimer

Please note: All templates / modules / resources in this repo are released for use "AS IS" without any warranties of
any kind, including, but not limited to their installation, use, or performance. We are not responsible for any damage,
data loss or charges incurred with their use. You are responsible for reviewing and testing any scripts you run
thoroughly before use in any production environment. This content is subject to change without notice.

### Contribute Code

We welcome contributions to this project, see [Contributing](CONTRIBUTING.md) for more details.
