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
}
# creating internetgateway to vpc
resource "aws_internet_gateway" "febintgt" {
  vpc_id = aws_vpc.febvpc.id
  tags = {
    "Name" ="febintgt"
  }
}
resource "aws_internet_gateway_attachment" "febintatt" {
  internet_gateway_id = aws_internet_gateway.febintgt.id
  vpc_id = aws_vpc.febvpc.id
}
# creating routetable and route and assiging it
 