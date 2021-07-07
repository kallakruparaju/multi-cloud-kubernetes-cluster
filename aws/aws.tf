provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}
resource "aws_vpc" "vpc1" {
  cidr_block       = "${var.range}"
  instance_tenancy = "default"

  tags = {
    Name ="${var.vpctag}"
  }
}
resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.vpc1.id}"
  cidr_block = "${var.subrange}"
  availability_zone = "${var.zones}"
  map_public_ip_on_launch = true
  depends_on = [aws_vpc.vpc1]

  tags = {
    Name = "${var.subnettag}"
  }
}
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc1.id}"
  depends_on = [aws_vpc.vpc1]
  tags = {
    Name = "${var.igtag}"
  }

}
resource "aws_route_table" "rtable" {
  vpc_id = "${aws_vpc.vpc1.id}"
  depends_on = [aws_internet_gateway.ig]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig.id}"

  }

  tags = {
    Name = "${var.rtag}"
  }
}
resource "aws_route_table_association" "routejoin" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.rtable.id}"
}

resource "aws_security_group" "cluster_sg" {
  name        = "cluster_group"
  description = "Allow all"
  vpc_id      = "${aws_vpc.vpc1.id}"

  ingress {
    description = "allow_all_ip"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

  tags = {
    Name = "{var.sgname}"
  }
}

resource "aws_instance" "masternode" {
  ami = "${var.amiid}"
  instance_type = "${var.ec2type}"
  key_name = "${var.keyname}"
  vpc_security_group_ids = [ "${aws_security_group.cluster_sg.id}" ]
  subnet_id = "${aws_subnet.public.id}" 
tags ={
    Name = "${var.k8_master}"
  }
  
}



resource "local_file" "inventoryfile" {
    content     = "[masternode]\n${aws_instance.masternode.public_ip}\tansible_ssh_user=ubuntu ansible_ssh_private_key_file=/home/kruparaju/kruparaju.pem  ansible_connection=ssh\n"
    filename = "/home/kruparaju/aws.txt"
    
    provisioner "local-exec"{

command ="echo $(cat /home/kruparaju/aws.txt >>/home/kruparaju/ipadr.txt;echo ''>>/home/kruparaju/ipadr.txt) "


}

}



