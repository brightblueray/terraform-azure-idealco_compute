# Create public IPs
resource "azurerm_public_ip" "pub_ip" {
    name                         = "${var.rg}_pubIP"
    location                     = var.location
    resource_group_name          = var.rg
    allocation_method            = "Dynamic"
}

# Create network interface
resource "azurerm_network_interface" "nic0" {
    name                      = "${var.rg}_nic0"
    location                  = var.location
    resource_group_name       = var.rg

    ip_configuration {
        name                          = "${var.rg}_nic0_config"
        subnet_id                     = var.subnet_id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.pub_ip.id
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        # resource_group = azurerm_resource_group.rg.name
        resource_group = var.rg
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "app_storAcct" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = var.rg
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"
}

# Create (and display) an SSH key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { 
    value = tls_private_key.ssh_key.private_key_pem 
    sensitive = true
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "app_instance1" {
  name                  = "${var.rg}__app"
  location              = var.location
  resource_group_name   = var.rg
  network_interface_ids = [azurerm_network_interface.nic0.id]
  size                  = var.azure_size
  computer_name                   = "bbr-app1"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  os_disk {
    name                 = "${var.rg}_disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.app_storAcct.primary_blob_endpoint
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
