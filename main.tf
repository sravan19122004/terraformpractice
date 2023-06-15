provider "aws" {
  region     = "ap-northeast-1"
  access_key = "AKIATQCNI3LUTUXQGGTC"
  secret_key = "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"
}


resource "aws_vpc" "ntier" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "ntier"
  }
}

resource "aws_internet_gateway" "gw1" {
  vpc_id = aws_vpc.ntier.id

  tags = {
    Name = "gw1"
  }
}


resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.ntier.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw1.id
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.ntier.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "practice-subnet2"
 }
}

resource "aws_route_table_association" "myrtassociation" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt.id
}


resource "aws_key_pair" "keypair" {
    key_name        = "fromterraform"
    public_key      = file("~/.ssh/id_rsa.pub")
}


resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound trafficc"
  vpc_id      = aws_vpc.ntier.id

   ingress {
     description      = "HTTPS"
     from_port        = 443
     to_port          = 443
     protocol         = "tcp"
     cidr_blocks      = ["0.0.0.0/0"]
   }

     ingress {
     description      = "HTTP"
     from_port        = 80
     to_port          = 80
     protocol         = "tcp"
     cidr_blocks      = ["0.0.0.0/0"]
   }

    ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "practice-sg1"
  }
}







resource "aws_instance" "web" {
  ami           = "ami-0ed99df77a82560e6"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.keypair.key_name
  tags = {
    Name = "newinstance"
  }
}
   