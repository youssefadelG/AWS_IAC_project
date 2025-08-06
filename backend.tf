terraform {
  backend "s3" {
    bucket = "905418379829-terraform-backend-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}