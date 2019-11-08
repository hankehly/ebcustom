provider "aws" {
  profile = "default"
  region  = var.region
}

# The resource block defines a resource that exists within the infrastructure
resource "aws_instance" "foo" {
  # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type
  ami           = "ami-04b9e92b5572fa0d1"
  instance_type = "t2.micro"
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.foo.id
}
