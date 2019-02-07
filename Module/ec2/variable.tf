variable "access-key" {
    default = "AKIAIFVGHPS5STOFVQFA"
}
variable "secret-key" {
  default =""
}
variable "region" {

}
variable "vpccidr" {
  description = "VPC cidr "
}
variable "subnetcidr" {
  description = "Subnet CIDR "
  default = {
      public = "10.0.0.0/26"
  }
}



