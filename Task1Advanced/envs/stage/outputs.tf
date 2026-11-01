output "vm" {
  description = "Created VM and attached disk"
  value       = module.vm_module
}

output "subnet_id" {
  description = "Created subnet ID"
  value       = aws_subnet.this.id
}
