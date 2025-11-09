terraform {
  backend "s3" {
    bucket = "terraform-remotestate-dockyard43526"
    key    = "ec2"
    region = "us-east-1"
    profile = "terraform_dockyard"
    use_lockfile = true
    dynamodb_table = "terraform_remotestate_locking"
  }
}