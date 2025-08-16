provider "" {
  
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