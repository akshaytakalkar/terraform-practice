module "ec2" {
  source = "./Module/ec2/"
  region = "ap-south-1"
  vpccidr = "10.0.0.0/24"
}
