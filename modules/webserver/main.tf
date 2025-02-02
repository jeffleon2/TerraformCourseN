resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name: "${var.env_prefix}-sg"
  }
}


data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [var.image_name]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}


// Se necesita tener ya creada una llave publica
// cat ~/.ssh/id_rsa.pub
resource "aws_key_pair" "ssh_key" {
  key_name = "server-key"
  public_key = var.my_public_key
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh_key.key_name
  
  # user_data = <<EOF
  #                 #!/bin/bash
  #                 sudo yum update -y && sudo yum install -y docker
  #                 sudo systemctl start docker
  #                 sudo usermod -aG docker ec2-user
  #                 docker run -p 8080:80 nginx
  #             EOF
  user_data = file("entry-script.sh")
  user_data_replace_on_change = true

  # connection {
  #   type = "ssh"
  #   host = self.public_ip
  #   user = "ec2-user"
  #   private_key = file(var.private_key_location)
  # }

  # provisioner "file" {
  #   source = "entry-script.sh"
  #   destination = "/home/ec2-user/entry-script.sh"
  # }

  # provisioner "remote-exec" {
  #   inline = [ "/home/ec2-user/entry-script.sh"]
  # }

  # provisioner "local-exec" {
  #   command = "echo ${self.public_ip} > output.txt"
  # }

  tags = {
    Name: "${var.env_prefix}-server"
  }
}
