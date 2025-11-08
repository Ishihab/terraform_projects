
provider "aws" {
  shared_config_files      = ["/home/sohrab/.aws/config"]
  shared_credentials_files = ["/home/sohrab/.aws/credentials"]
  profile                  = "terraform_dockyard"
  region                   = "us-east-1"
}
