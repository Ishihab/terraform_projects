terraform {
  backend "s3" {
    bucket = "terraform-remotestate-dockyard43526"
    key    = "s3_static_web/terraform.tfstate"
    region = "us-east-1"
    profile = "terraform_dockyard"
    use_lockfile = true
    dynamodb_table = "terraform_remotestate_locking"
  }
}