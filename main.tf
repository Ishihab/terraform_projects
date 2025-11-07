resource "aws_instance" "demo" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.ssh_key.key_name
  tags = {
  name = "demo"
}   
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "architecture"
    values = ["x86_64"]
}
}

output "ami_id" {
   value = data.aws_ami.ubuntu.id
}


resource "aws_key_pair" "ssh_key" {
  key_name = "demo_test_ssh_key"
  public_key = file("/home/sohrab/.ssh/aws_ec2_terraform.pub")

}


output "ec2_public_ip" {
 value = aws_instance.demo.public_ip
}
