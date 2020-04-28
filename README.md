# Cloud Install 

This repository contains Terraform templates to provision public cloud infrastructure (i.e. AWS, Azure) where IBM Spectrum Scale can then be installed. 

| IBM Spectrum Scale is NOT installed at the conclusion of running these templates.  For assistance with installation of IBM Spectrum Scale, see https://github.com/IBM/ibm-spectrum-scale-install-infra. |
| --- |

## Prerequisites

Ensure that the following requirements are met on the server where this repository is cloned. 

* Install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) and validate:

    * `terraform -v`

* Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) and validate: 

    * `ansible --version` 
    * `ansible-vault -- version`

* Create a `keyring` file containing the desired passphrase. The `keyring` file is used by `ansible-vaule`. 

    ```
    $ mkdir -p ~/tf_data_path/
    $ echo 'Spectrumscale!' >> ~/tf_data_path/keyring
    ```

    | Note: We recommend changing `Spectrumscale!` to your desired passphrase. The generated SSH keys are encrypted using the passphrase mentioned in `keyring` file.  Keep this file safe for debugging. |
    | --- |

## Usage

  * [Amazon Web Services (AWS)](docs/aws.md)
  * [Microsoft Azure (Azure)](docs/azure.md)


### Reporting Issues and Feedback

To file issues, suggestions, new features, etc., please open an [Issue](https://github.com/IBM/ibm-spectrum-scale-cloud-install/issues).

### Disclaimer

Please note: all templates / modules / resources in this repo are released for use "AS IS" without any warranties of
any kind, including, but not limited to their installation, use, or performance. We are not responsible for any damage
or charges or data loss incurred with their use. You are responsible for reviewing and testing any scripts you run
thoroughly before use in any production environment. This content is subject to change without notice.

### Contribute Code

We welcome contributions to this project, see [Contributing](CONTRIBUTING.md) for more details.
