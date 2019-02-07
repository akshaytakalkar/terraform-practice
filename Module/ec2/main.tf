provider "aws" {
access_key = "${var.access-key}"
secret_key = "${var.secret-key}"
region = "${var.region}"  
}

resource "aws_vpc" "dev-vpc" {
  cidr_block = "${var.vpccidr}"
  #default_route_table_id =""
  #default_network_acl_id =""
  #default_security_group_id = ""
    tags{
        Name = "Dev-VPC" 
        Terraform = "true"
    }
}


resource "aws_internet_gateway" "dev-igw" {
  vpc_id = "${aws_vpc.dev-vpc.id}"
  tags{
      Name="Dev-IGW"
  }
}

resource "aws_flow_log" "dev-flowlog" {
  iam_role_arn = "${aws_iam_role.flow-log_role.arn}"
  log_destination ="${aws_cloudwatch_log_group.dev-log.arn}"
  traffic_type="ALL"
  vpc_id="${aws_vpc.dev-vpc.id}"
}
resource "aws_cloudwatch_log_group" "dev-log" {
  name = "Dev-VPC-log"
}
resource "aws_iam_role" "flow-log_role" {
  name = "flowlog-create-access"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "flow-log_policy" {
  name = "VPC-flow-log_policy"
  role = "${aws_iam_role.flow-log_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

###Adding Route table

resource "aws_route_table" "dev-public-rt" {
  vpc_id = "${aws_vpc.dev-vpc.id}"
  tags{
    Name="Dev-public-RT"
    Terraform="true"
  }
  route{
      cidr_block="0.0.0.0/0"
      gateway_id= "${aws_internet_gateway.dev-igw.id}"
  }
}

resource "aws_route_table" "dev-private-rt" {
  vpc_id = "${aws_vpc.dev-vpc.id}"
  tags{
    Name="Dev-private-RT"
    Terraform="true"
  }
}

#Adding NACL 
resource "aws_network_acl" "dev-public-nacls" {
  vpc_id = "${aws_vpc.dev-vpc.id}"
  egress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags{
      Name="Dev-Public-NACL"
  }
}

resource "aws_network_acl" "dev-private-nacls" {
  vpc_id = "${aws_vpc.dev-vpc.id}" 
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "${var.vpccidr}"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "${var.vpccidr}"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "all"
    rule_no    = 201
    action     = "allow"
    cidr_block = "${var.vpccidr}"
    from_port  = 0
    to_port    = 0
  }

  tags{
      Name = "Dev-Private-NACLS"
      Terraform = "true"
  }
}



#Adding Subnet
##uncomplete
/*
resource "aws_subnet" "private-subnet" {
  vpc_id= "${aws_vpc.dev-vpc.id}"
  cidr_block= "${lookup(var.subnetcidr, key, [default])}"
}

*/