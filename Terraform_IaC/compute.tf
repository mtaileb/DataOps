resource "azurerm_network_interface" "nic" {
  name                = "demo-terraform-nic"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "10-ip"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = "demoterraformm2i"
}

resource "azurerm_storage_account" "stor" {
  name                     = "stockagedemoterraform"
  location                 = "West Europe"
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "ma-vm"
  location              = "West Europe"
  resource_group_name   = azurerm_resource_group.rg.name
  vm_size               = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.nic.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "mon-os-disque"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "VM"
    admin_username = "toto"
    admin_password = "toto123*"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.stor.primary_blob_endpoint
  }
}

