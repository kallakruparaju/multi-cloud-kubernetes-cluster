resource "azurerm_resource_group" "myterraformgroup" {
    name     = "terraform"
    location = "eastus"
}

resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup.name

}

resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"
}
resource "azurerm_public_ip" "myterraformpublicip1" {
    name                         = "myPublicIP1"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"
}

resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface" "myterraformnic" {
    name                      = "myNIC"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }
}

resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

resource "azurerm_network_interface" "myterraformnic1" {
    name                      = "myNIC1"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "myNicConfiguration1"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip1.id
    }
}

resource "azurerm_network_interface_security_group_association" "example1" {
    network_interface_id      = azurerm_network_interface.myterraformnic1.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}


resource "azurerm_linux_virtual_machine" "myslavevm1" {
    name                  = "slavenode1"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = "Standard_B2s"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

     source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name         = "myvm"
    admin_username        = "azureuser"
    admin_password        = "Terraform@12"
    disable_password_authentication = false
}

resource "azurerm_linux_virtual_machine" "myslavevm2" {
    name                  = "slavenode2"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic1.id]
    size                  = "Standard_B2s"

    os_disk {
        name              = "myOsDisk2"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name         = "myvm1"
    admin_username        = "azureuser"
    admin_password        = "Terraform@12"
    disable_password_authentication = false
}

resource "local_file" "inventoryfile" {
    content     = "[slavenode]\n${azurerm_linux_virtual_machine.myslavevm1.public_ip_address}\tansible_ssh_user=azureuser ansible_ssh_password=Terraform@12  ansible_connection=ssh\n${azurerm_linux_virtual_machine.myslavevm2.public_ip_address}\tansible_ssh_user=azureuser ansible_ssh_password=Terraform@12  ansible_connection=ssh"
    filename = "/home/kruparaju/azure.txt"
    provisioner "local-exec"{

command ="echo $(echo ''>>/home/kruparaju/ipadr.txt;cat /home/kruparaju/azure.txt >>/home/kruparaju/ipadr.txt ) "


}

}

