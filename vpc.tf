resource "aws_vpc" "primary-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.primary-vpc.id
}

resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.primary-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "${var.aws_region}a"
    map_public_ip_on_launch = true
    depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "public-routes" {
    route_table_id = aws_vpc.primary-vpc.default_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table" "igw-route" {
    vpc_id = aws_vpc.primary-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "route-out" {
    route_table_id = aws_route_table.igw-route.id
    subnet_id      = aws_subnet.public-subnet.id
}