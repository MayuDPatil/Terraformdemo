# here I'm creating linux instance
provider "aws" {
  region = "us-east-1" # Replace with your desired region
}
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = "subnet-yoursubnet id"
  vpc_security_group_ids = ["sg-yourdefault security group id"]

  tags = {
    Name = "HelloWorld"
  }
}
