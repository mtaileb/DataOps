## Ensure you're using 2.0+ of the azurevm provider to get the azurerm_windows_virtual_machine reosurce and
## the other resources and capabilities
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.92.0"
    }
  }
}
provider "azurerm" {
  features {}
}

## Create an Azure resource group using the value of resource_group and the location of the location variable
## defined in the terraform.tfvars file.
resource "azurerm_resource_group" "monolithRG" {
  name     = var.resource_group
  location = var.location
}

## Create an availability set called monolith-as which the VMs will go into using the same location and resource
## group
resource "azurerm_availability_set" "monolith-as" {
  name                = "monolith-as"
  location            = azurerm_resource_group.monolithRG.location
  resource_group_name = azurerm_resource_group.monolithRG.name
}


  
## Create a simple vNet
resource "azurerm_virtual_network" "main" {
  name                = "monolith-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.monolithRG.location
  resource_group_name = azurerm_resource_group.monolithRG.name
}

## Create a simple subnet inside of th vNet ensuring the VMs are created first (depends_on)
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.monolithRG.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.0.2.0/24"

  depends_on = [
    azurerm_virtual_network.main
  ]
}

## You need a public IP to assign to the load balancer for client applications to 
## connect to the web app. Ensure this is static otherwise, the deployment will go through without
## error but an IP will not be assigned.
resource "azurerm_public_ip" "lbIp" {
  name                    = "publicLbIp"
  location                = azurerm_resource_group.monolithRG.location
  resource_group_name     = azurerm_resource_group.monolithRG.name
  allocation_method       = "Static"
}

## You'll need public IPs for each VM for Ansible to connect to and to deploy the web app to.
resource "azurerm_public_ip" "vmIps" {
  count                   = 2
  name                    = "publicVmIp-${count.index}"
  location                = azurerm_resource_group.monolithRG.location
  resource_group_name     = azurerm_resource_group.monolithRG.name
  allocation_method       = "Dynamic"
  domain_name_label       = "${var.domain_name_prefix}-${count.index}"
}

## Create a vNic for each VM. Using the count property to create two vNIcs while using ${count.index}
## to refer to each VM which will be defined in an array
resource "azurerm_network_interface" "main" {
  count               = 2
  name                = "monolith-nic-${count.index}"
  location            = azurerm_resource_group.monolithRG.location
  resource_group_name = azurerm_resource_group.monolithRG.name
  
  ## Simple ip configuration for each vNic
  ip_configuration {
    name                          = "ip_config"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vmIps[count.index].id
  }
  
  ## Ensure the subnet is created first before creating these vNics.
  depends_on = [
    azurerm_subnet.internal
  ]
}


## Create the load balancer with a frontend configuration using the public
## IP address created earlier.
resource "azurerm_lb" "LB" {
 name                = "nobsloadbalancer"
 location            = azurerm_resource_group.monolithRG.location
 resource_group_name = azurerm_resource_group.monolithRG.name

 frontend_ip_configuration {
   name                 = "lb_frontend"
   public_ip_address_id = azurerm_public_ip.lbIp.id
 }
}

## Create and assign a backend address pool which will hold both VMs behind the load balancer
resource "azurerm_lb_backend_address_pool" "be_pool" {
 resource_group_name = azurerm_resource_group.monolithRG.name
 loadbalancer_id     = azurerm_lb.LB.id
 name                = "BackEndAddressPool"
}

## Assign both vNics on the VMs to the backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "be_assoc" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name   = "ip_config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.be_pool.id
}

## Create a health probe which will periodically check for an open port 80
## on both VMs connected to the load balancer.
resource "azurerm_lb_probe" "lbprobe" {
  resource_group_name = azurerm_resource_group.monolithRG.name
  loadbalancer_id     = azurerm_lb.LB.id
  name                = "http-running-probe"
  port                = 80
}

## Create a rule on the load balancer to forward all incoming traffic on port 80
## to the VMs in the backend address pool usin the health probe defined above
## to know which VMs are available.
resource "azurerm_lb_rule" "lbrule" {
  resource_group_name            = azurerm_resource_group.monolithRG.name
  loadbalancer_id                = azurerm_lb.LB.id
  name                           = "LBRule"
  probe_id                       = azurerm_lb_probe.lbprobe.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_id        = azurerm_lb_backend_address_pool.be_pool.id
  frontend_ip_configuration_name = "lb_frontend"
}

## Create the two Windows VMs associating the vNIcs created earlier
resource "azurerm_windows_virtual_machine" "monolithVMs" {
  count                 = 2
  name                  = "monolithvm-${count.index}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.monolithRG.name
  size                  = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.main[count.index].id]
  availability_set_id   = azurerm_availability_set.monolith-as.id
  computer_name         = "monolithvm-${count.index}"
  admin_username        = "testadmin"
  admin_password        = "Password1234!"
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  depends_on = [
    azurerm_network_interface.main
  ]
}

## Install the custom script VM extension to each VM. When the VM comes up,
## the extension will download the ConfigureRemotingForAnsible.ps1 script from GitHub
## and execute it to open up WinRM for Ansible to connect to it from Azure Cloud Shell.
## exit code has to be 0
resource "azurerm_virtual_machine_extension" "enablewinrm" {
  count                 = 2
  name                  = "enablewinrm"
  virtual_machine_id    = azurerm_windows_virtual_machine.monolithVMs[count.index].id
  publisher            = "Microsoft.Compute" ## az vm extension image list --location eastus Do not use Microsoft.Azure.Extensions here
  type                 = "CustomScriptExtension" ## az vm extension image list --location eastus Only use CustomScriptExtension here
  type_handler_version = "1.9" ## az vm extension image list --location eastus
  auto_upgrade_minor_version = true
  settings = <<SETTINGS
    {
      "fileUris": ["https://github.com/mtaileb/DataOps/raw/main/Terraform_avec_Azure/Etude_de_cas/ConfigureRemotingForAnsible.ps1"],
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1"
    }
SETTINGS
}

output "VMIps" {
  value       = azurerm_public_ip.vmIps.*.ip_address
}

## Return the load balancer's public IP address so we know what IP we can connect to and test this.
output "Load_Balancer_IP" {
  value       = azurerm_public_ip.lbIp.ip_address
}
