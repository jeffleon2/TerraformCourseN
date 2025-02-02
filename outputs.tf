output "ec2_public_id" {
  value = module.myapp-webserver.instance.public_ip
}
