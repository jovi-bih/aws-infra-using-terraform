# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "sub3" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub4" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  }

  resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id
  
 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  }

  resource "aws_route_table_association" "rt1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_route_table_association" "rt2" {
  subnet_id      = aws_subnet.sub3.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_security_group" "websg" {
  name        = "websg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

ingress{
    description    = "HTTP from VPC"
    cidr_blocks    = ["0.0.0.0/0"]
    from_port      = 80
    protocol       = "tcp"
    to_port        = 80
}
ingress{
    description    = "SSH from VPC"
    cidr_blocks    = ["0.0.0.0/0"]
    from_port      = 22
    protocol       = "tcp"
    to_port        = 22
}
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "joviterraformproject"
}

resource "aws_s3_bucket_public_access_block" "mybucket" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.mybucket.id
  acl    = "public-read"
}

resource "aws_instance" "webserver1" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.websg.id]
  subnet_id = aws_subnet.sub1.id
  user_data = base64decode(file("userdata_encoded.sh"))
}

resource "aws_instance" "webserver2" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.websg.id]
  subnet_id = aws_subnet.sub3.id
  user_data = base64decode(file("userdata1_encoded.sh"))
}