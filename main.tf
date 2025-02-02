// Guarda el estado remoto para que todos los miembros
// del equipo puedan tener el mismo estado el bucket
// debe estar creado
// se debe hacer terraform init
terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "myapptest-terraformbucket"
    key = "myapp/state.tfstate"
    region = "us-east-1"
  }
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

module "myapp-subnet" {
  source = "./modules/subnet"
  vpc_id = aws_vpc.myapp-vpc.id
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
}

module "myapp-webserver" {
  source = "./modules/webserver"
  env_prefix = var.env_prefix
  my_ip = var.my_ip
  vpc_id = aws_vpc.myapp-vpc.id
  instance_type = var.instance_type
  my_public_key = var.my_public_key
  private_key_location = var.private_key_location
  avail_zone = var.avail_zone
  image_name = var.image_name
  subnet_id = module.myapp-subnet.subnet.id
}
