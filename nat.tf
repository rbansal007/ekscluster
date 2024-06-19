resource "aws_eip" "nat" {
 
  tags = {
    Name = "eip_nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-us-east-1a.id

  tags = {
    Name = "ramit_nat"
  }

  depends_on = [aws_internet_gateway.igw]
}
