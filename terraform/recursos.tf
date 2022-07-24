# Creamos direccionamiento IP
resource "azurerm_virtual_network" "red-principal" {
  name                = "${var.identificador}-red"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.cp2-rg.location
  resource_group_name = azurerm_resource_group.cp2-rg.name
}

resource "azurerm_subnet" "red-interna" {
  name                 = "${var.identificador}-interna"
  resource_group_name  = azurerm_resource_group.cp2-rg.name
  virtual_network_name = azurerm_virtual_network.red-principal.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "ip_publica_1" {
  name                = "${var.identificador}-ip_publica-master"
  location            = azurerm_resource_group.cp2-rg.location
  resource_group_name = azurerm_resource_group.cp2-rg.name
  allocation_method   = "Dynamic"
}
resource "azurerm_public_ip" "ip_publica_2" {
  name                = "${var.identificador}-ip_publica-worker"
  location            = azurerm_resource_group.cp2-rg.location
  resource_group_name = azurerm_resource_group.cp2-rg.name
  allocation_method   = "Dynamic"
}
resource "azurerm_public_ip" "ip_publica_3" {
  name                = "${var.identificador}-ip_publica-nfs"
  location            = azurerm_resource_group.cp2-rg.location
  resource_group_name = azurerm_resource_group.cp2-rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic-1" {
  name                = "${var.identificador}-nic1"
  location            = azurerm_resource_group.cp2-rg.location
  resource_group_name = azurerm_resource_group.cp2-rg.name

  ip_configuration {
    name                          = "${var.identificador}-conf-ip-nic1"
    subnet_id                     = azurerm_subnet.red-interna.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip_publica_1.id
  }
}

resource "azurerm_network_interface" "nic-2" {
  name                = "${var.identificador}-nic2"
  location            = azurerm_resource_group.cp2-rg.location
  resource_group_name = azurerm_resource_group.cp2-rg.name

  ip_configuration {
    name                          = "${var.identificador}-conf-ip-nic2"
    subnet_id                     = azurerm_subnet.red-interna.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip_publica_2.id
  }
}

resource "azurerm_network_interface" "nic-3" {
  name                = "${var.identificador}-nic3"
  location            = azurerm_resource_group.cp2-rg.location
  resource_group_name = azurerm_resource_group.cp2-rg.name

  ip_configuration {
    name                          = "${var.identificador}-conf-ip-nic3"
    subnet_id                     = azurerm_subnet.red-interna.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip_publica_3.id
  }
}
# *** Configuración VM1 Master ***
resource "azurerm_linux_virtual_machine" "vm1-master" {
  computer_name         = "master"
  name                  = "${var.identificador}-vm1-master"
  location              = azurerm_resource_group.cp2-rg.location
  resource_group_name   = azurerm_resource_group.cp2-rg.name
  network_interface_ids = [azurerm_network_interface.nic-1.id]
  size                  = "Standard_DS2_v2"
  admin_username        = var.ssh_user

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.public_key_path)
  }

  os_disk {
    name                 = "os-disk-vm1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = "centos-8-stream-free"
    product   = "centos-8-stream-free"
    publisher = "cognosys"
  }
  source_image_reference {
    publisher = "cognosys"
    offer     = "centos-8-stream-free"
    sku       = "centos-8-stream-free"
    version   = "22.03.28"
  }
}
# *** Configuración VM2 Worker ****
resource "azurerm_linux_virtual_machine" "vm2-worker" {
  computer_name         = "worker"
  name                  = "${var.identificador}-vm2-worker"
  location              = azurerm_resource_group.cp2-rg.location
  resource_group_name   = azurerm_resource_group.cp2-rg.name
  network_interface_ids = [azurerm_network_interface.nic-2.id]
  size                  = "Standard_DS2_v2"
  admin_username        = var.ssh_user

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.public_key_path)
  }

  os_disk {
    name                 = "os-disk-vm2"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = "centos-8-stream-free"
    product   = "centos-8-stream-free"
    publisher = "cognosys"
  }
  source_image_reference {
    publisher = "cognosys"
    offer     = "centos-8-stream-free"
    sku       = "centos-8-stream-free"
    version   = "22.03.28"
  }
}
# *** Configuración VM3 NFS ***
resource "azurerm_linux_virtual_machine" "vm3-nfs" {
  computer_name         = "nfs"
  name                  = "${var.identificador}-vm3-nfs"
  location              = azurerm_resource_group.cp2-rg.location
  resource_group_name   = azurerm_resource_group.cp2-rg.name
  network_interface_ids = [azurerm_network_interface.nic-3.id]
  size                  = "Standard_F2"
  admin_username        = var.ssh_user

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.public_key_path)
  }

  os_disk {
    name                 = "os-disk-vm3"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = "centos-8-stream-free"
    product   = "centos-8-stream-free"
    publisher = "cognosys"
  }
  source_image_reference {
    publisher = "cognosys"
    offer     = "centos-8-stream-free"
    sku       = "centos-8-stream-free"
    version   = "22.03.28"
  }
}



