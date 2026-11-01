output "vm_id" {
  description = "EC2 instance ID"
  value       = aws_instance.vm.id
}

output "vm_name" {
  description = "EC2 Name tag"
  value       = var.name
}

output "private_ip" {
  description = "Private IPv4 address"
  value       = aws_instance.vm.private_ip
}

output "public_ip" {
  description = "Public IPv4 address, if assigned"
  value       = aws_instance.vm.public_ip
}

output "disk_id" {
  description = "Additional EBS volume ID"
  value       = aws_ebs_volume.data.id
}

output "instance_type" {
  description = "EC2 type selected from CPU and RAM"
  value       = aws_instance.vm.instance_type
}
