# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
#### Step 1: Starting by cloning the repository to your local machine to access all the necessary configuration files.
   ```sh
   git clone <repository-url>
   ```
#### Step 2: Creating a Custom VM Image with Packer
- Before building the image, ensure you have a Service Principal (SPN) in Azure:
  - Application ID: client_id.
  - Client Secret: Password for the Service Principal.
  - Subscription ID: Your Azure subscription identifier.
     
- Modify the packer template: 
		In server.json, update the builders with the requirements and your own SPN details, build the image in Packer by execute the following command:

  ```sh
   packer build server.json
  ```
#### Step 3: Deploying the Infrastructure
- Initialize Terraform:
  Apply the Terraform configuration to provision the infrastructure

  ```sh
   terraform init
  ```
- Configure Terraform Variables by create and customize the vars.tf file, modify variables with the key variables so items can be user-configurable:
  - Prefix: the prefix which should be used to for all resources.
  - Resource_group_name: name of the resource group where resources will be created.
  - Location: specify the Azure region (e.g., eastus or westeurope).
  - vm_count: define the min number of virtual machines to be deployed (ensure the value is within the supported range).
- Plan the Deployment
  Generate a deployment plan to preview the resources Terraform will create:

  ```sh
   terraform plan -out udacity.plan
  ```
- Apply the Terraform
  Finally, apply the Terraform configuration to provision the infrastructure:
  
  ```sh
  terraform apply "udacity.plan"    
  ```
### Customizing infrastructure:
- Packer Template:
  - Base Image: update the source_image_reference in the server.json file to specify a custom base image.
  - Provisioning: modify the software and configuration installed during build process
  - Resource Group: define the azure Resource Group where t he custom image will be saved.
- Terraform template:
  Customize the infrastructure by modifying the variables in the vars.tf file:
   - Prefix: define the prefix for all resources.
   - Resource_group_name: specify the name of the Azure Resource Group where all resources will be created.
   - Location: specify the Azure region (e.g., eastus or westeurope).
   - vm_count: define the min number of virtual machines to be deployed (ensure the value is within the supported range).

### Output
Once the process is complete, the following resources will be available in Azure:
- A custom VM image stored in provided subscription.
- A fully configured infrastructure, including:
   - A Virtual Network (VNet) and Subnet on the same virtual network.
   - Network Security Groups (NSGs) for securing traffic.
   - Network interface
   - Public IP
   - Load balance
   - Virtual machine availability set
   - Virtual machine Deployed based on the custom image.
     
This infrastructure is designed as a scalable web server solution, offering the flexibility to be further customized and expanded based on specific requirements. 
