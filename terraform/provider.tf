provider "aws" {
  
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1" # obligatorio para certificados de CloudFront
}

terraform {
  backend "s3" {
    bucket = "tf-resources-jar-gha"
    region = "us-east-2"
    key = "github-actions/terraform.tfstate"
    encrypt = true
    dynamodb_table = "tf-resources-jar-gha-lock"
  }
 
} 