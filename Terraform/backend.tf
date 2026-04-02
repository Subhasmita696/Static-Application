terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "infra/terraform.tfstate"
    region = "eu-west-1"
  }
}