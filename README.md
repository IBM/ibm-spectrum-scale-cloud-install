# IBM Spectrum Scale Cloud Install

IBM Spectrum Scale is a high-performance, highly available clustered file system and associated management software, and is available on a variety of platforms. It offers many features beyond common data access including data replication, policy based storage management, encryption, and multi-site operations. The `ibm-spectrum-scale-cloud-install` provides terraform templates (built based on best cloud practices) to provision public cloud infrastructure (i.e. AWS, Azure, GCP, IBM Cloud) where IBM Spectrum Scale can be deployed for users who require highly available access to a shared namespace across multiple instances.

## IBM Spectrum Scale - Cluster Configuration

IBM Spectrum Scale™ cluster can be configured in a variety of ways. The cluster can be a heterogeneous mix of hardware platforms, virtualized instances and operating systems. Using these templates, Spectrum Scale cluster can be deployed in below architectures;

- IBM Spectrum Scale Architecture (Single Availability zone)

- IBM Spectrum Scale Architecture (Multi Availability zone)

## IBM Spectrum Scale - Product Editions

IBM Spectrum Scale offers different editions based on functional levels.
- IBM Spectrum Scale Standard Edition
- IBM Spectrum Scale Data Access Edition
- IBM Spectrum Scale Advanced Edition
- IBM Spectrum Scale Data Management Edition (**Recommended for Cloud usecases**)
- IBM Spectrum Scale Erasure Code Edition
- IBM Spectrum Scale Developer Edition

  > Learn, develop and test with IBM Spectrum Scale™, for `non-production use`. Developer edition provides all the features of the Data Management Edition and it is limited to 12 TB per cluster. It can be downloaded from [IBM Market place](https://www.ibm.com/products/spectrum-scale)

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
  * [IBM Cloud](docs/ibmcloud.md)

### Reporting Issues and Feedback

To file issues, suggestions, new features, etc., please open an [Issue](https://github.com/IBM/ibm-spectrum-scale-cloud-install/issues).

### Disclaimer

Please note: All templates / modules / resources in this repo are released for use "AS IS" without any warranties of
any kind, including, but not limited to their installation, use, or performance. We are not responsible for any damage,
data loss or charges incurred with their use. You are responsible for reviewing and testing any scripts you run
thoroughly before use in any production environment. This content is subject to change without notice.

### Contribute Code

We welcome contributions to this project, see [Contributing](CONTRIBUTING.md) for more details.
