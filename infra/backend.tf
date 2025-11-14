terraform {
  backend "s3" {
    bucket         = "chariis-terraform-state"
    key            = "global/cloud-resume/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "chariis-terraform-state-lock"
    encrypt        = true
  }
}
