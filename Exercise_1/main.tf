# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "/Users/akinnurunoluwafemi/.aws/credentials"
}

# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "UdacityT2" {
    count = 4
    ami = "ami-0c6b1d09930fac512"
    instance_type = "t2.micro"
    subnet_id = "subnet-bb1ea0f6"
    
    tags = {
        Name = "Udacity T2"
    }

}

# TODO: provision 2 m4.large EC2 instances named Udacity M4
resource "aws_instance" "UdacityM4" {
    ami = "ami-0c6b1d09930fac512"
    instance_type = "m4.large"
    subnet_id = "subnet-bb1ea0f6"
    count = 2
    tags  = {
        Name = "Udacity M4"
    }
}

