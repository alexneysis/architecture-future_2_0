environment = "dev"
region      = "us-east-1"
cores       = 2
memory      = 1
disk_size   = 10
vpc_cidr    = "10.10.0.0/16"
subnet_cidr = "10.10.1.0/24"

# Read the public key locally; never put a private key in Terraform.
ssh_key_path = "~/.ssh/id_ed25519.pub"
public_ip    = true
