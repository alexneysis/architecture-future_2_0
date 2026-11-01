terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

locals {
  # AWS allocates CPU and RAM together as an instance type.
  instance_types = {
    "2-1"  = "t3.micro"
    "2-2"  = "t3.small"
    "2-4"  = "t3.medium"
    "2-8"  = "t3.large"
    "4-16" = "t3.xlarge"
    "8-32" = "t3.2xlarge"
  }
  resource_pair = "${var.cores}-${var.memory}"
}

data "aws_subnet" "selected" {
  id = var.subnet_id
}

resource "aws_key_pair" "ssh" {
  key_name_prefix = "${var.name}-"
  public_key      = trimspace(var.ssh_key)
}

resource "aws_security_group" "vm" {
  name_prefix = "${var.name}-"
  description = "SSH access for the training VM"
  vpc_id      = data.aws_subnet.selected.vpc_id

  ingress {
    description = "SSH from the user public IPv4"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-sg" }
}

resource "aws_instance" "vm" {
  ami = var.image_id
  # The precondition rejects unsupported pairs before EC2 is created.
  instance_type               = lookup(local.instance_types, local.resource_pair, "t3.micro")
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.vm.id]
  key_name                    = aws_key_pair.ssh.key_name
  associate_public_ip_address = var.public_ip

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_size           = var.boot_disk_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_tokens = "required"
  }

  lifecycle {
    precondition {
      condition     = contains(keys(local.instance_types), local.resource_pair)
      error_message = "Supported CPU/RAM pairs (GiB): 2/1, 2/2, 2/4, 2/8, 4/16, 8/32."
    }
  }

  tags = { Name = var.name }
}

resource "aws_ebs_volume" "data" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = var.disk_size
  type              = "gp3"
  encrypted         = true
  tags              = { Name = "${var.name}-data" }
}

resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.vm.id
}
