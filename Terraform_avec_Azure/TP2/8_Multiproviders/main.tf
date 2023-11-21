resource "azurerm_resource_group" "rg" {
  name     = "demoRg"
  location = "West Europe"  
}

resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}
