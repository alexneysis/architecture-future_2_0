mock_provider "aws" {
  mock_data "aws_subnet" {
    defaults = {
      vpc_id            = "vpc-00000000000000000"
      availability_zone = "us-east-1a"
    }
  }
}

variables {
  name      = "future-test"
  cores     = 2
  memory    = 1
  disk_size = 10
  subnet_id = "subnet-00000000000000000"
  ssh_cidr  = "203.0.113.10/32"
  ssh_key   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA test"
  image_id  = "ami-00000000000000000"
}

run "micro_and_subnet_zone" {
  command = plan

  assert {
    condition     = aws_instance.vm.instance_type == "t3.micro"
    error_message = "2 vCPU and 1 GiB must select t3.micro."
  }

  assert {
    condition     = aws_ebs_volume.data.availability_zone == data.aws_subnet.selected.availability_zone
    error_message = "The data disk must be in the subnet availability zone."
  }

  assert {
    condition     = one(aws_security_group.vm.ingress).cidr_blocks == toset([var.ssh_cidr])
    error_message = "SSH must only allow the requested IPv4 range."
  }
}

run "small" {
  command = plan
  variables {
    memory = 2
  }
  assert {
    condition     = aws_instance.vm.instance_type == "t3.small"
    error_message = "2 vCPU and 2 GiB must select t3.small."
  }
}

run "reject_unsupported_pair" {
  command = plan
  variables {
    cores  = 4
    memory = 4
  }
  expect_failures = [aws_instance.vm]
}
