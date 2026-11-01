terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = "future-2-0"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "future-${var.environment}-vpc" }
}

resource "aws_subnet" "this" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags                    = { Name = "future-${var.environment}-subnet" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "future-${var.environment}-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = { Name = "future-${var.environment}-public" }
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.public.id
}

module "vm_module" {
  source = "../../modules/vm"

  name           = "future-${var.environment}"
  cores          = var.cores
  memory         = var.memory
  disk_size      = var.disk_size
  boot_disk_size = var.boot_disk_size
  subnet_id      = aws_subnet.this.id
  ssh_key        = file(pathexpand(var.ssh_key_path))
  ssh_cidr       = var.ssh_cidr
  image_id       = data.aws_ami.ubuntu.id
  public_ip      = var.public_ip
}
