resource "aws_vpc" "febvpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "febvpc"
    }
}
# creating subnet
resource "aws_subnet" "febsub" {
  vpc_id = aws_vpc.febvpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    "Name" = "febsub"
  }
  depends_on = [
    aws_vpc.febvpc
  ]
}
# creating internetgateway to vpc
resource "aws_internet_gateway" "febintgt" {
  vpc_id = aws_vpc.febvpc.id
  tags = {
    "Name" ="febintgt"
  }
}
/*
resource "aws_internet_gateway_attachment" "febintatt" {
  internet_gateway_id = aws_internet_gateway.febintgt.id
  vpc_id = aws_vpc.febvpc.id
}
*/
# creating routetable and route and assiging it 
resource "aws_route_table" "pubrt"{
  vpc_id = aws_vpc.febvpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.febintgt.id 
  }
  tags ={
    "Name"= "febpubrt"
  }
}
# associating public route table to subnet 
resource "aws_route_table_association" "febrtass"{
  subnet_id = aws_subnet.febsub.id 
  route_table_id = aws_route_table.pubrt.id 
  depends_on =[
    aws_subnet.febsub
  ]
}

# creating security group 
resource "aws_security_group" "feb_sg"{
  vpc_id = aws_vpc.febvpc.id 
  description = "This to allow traffic "
  ingress {
    description = "allow ssh"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = [ "0.0.0.0/0" ]    
  }
  ingress {
    description = "allow http"
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress{
    description = "allow https"
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = [ "0.0.0.0/0"]
  }
  egress {
    description = "allow all"
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = {
    "Name" = "feb_sg"
  }
} 

# creating an instance with provisioning connection 
resource "aws_instance" "febec2"{
  ami = "ami-06984ea821ac0a879" // mumbai region ami 
  subnet_id = aws_subnet.febsub.id 
  instance_type = "t2.micro"
  key_name = "pckey"
  vpc_security_group_ids = [ "aws_security_group.feb_sg.id" ]
  associate_public_ip_address = true
  root_block_device {
    volume_size = 8
  }
  tags = {
    "Name" = "febec2"
  }
  connection {
    type= "ssh"
    user= "ubuntu"
    port= 22
    host= self.public_ip
    private_key= file("~/.ssh/id_rsa")
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install openjdk-11-jdk -y",
      "sudo apt install unzip wget -y",
      "sudo apt install software-properties-common && / sudo add-apt-repository --yes --update ppa:ansible/ansible && /sudo apt install ansible -y",
       "whoami",
       "sudo touch inventory",
       "sudo echo'localhost' > inventory "

    ]
    
  }
} 