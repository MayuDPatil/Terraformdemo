resource "aws_vpc" "myvpc"{
  cidr_block = var.cidr
  tags = {
     Name = "myvpc"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "sub2" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw"{
  vpc_id = aws_vpc.myvpc.id
}
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
        }
}
resource "aws_route_table_association"  "rta1"{
  subnet_id = aws_subnet.sub1.id
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
        }
}
resource "aws_route_table_association"  "rta1"{
  subnet_id = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}
resource "aws_route_table_association"  "rta2"{
  subnet_id = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "allow_all"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssl_ipv4" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = aws_vpc.myvpc.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = aws_vpc.myvpc.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_s3_bucket" "example" {
  bucket = "my-terraform-bucket123"
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.example.id
  acl    = "public-read"
}

# here I'm creating linux instance

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
  ami           = "ami-0e2c8caa4b6378d8c"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.sub1.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  user_data     = base64encode(file("userdata.sh"))

}

resource "aws_instance" "web1" {
  ami           = "ami-0e2c8caa4b6378d8c"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.sub2.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  user_data     = base64encode(file("userdata2.sh"))
}
