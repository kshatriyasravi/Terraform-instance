# This is a provider file, were we define the provider we are going to use in our terraform code.
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = "~> 5.0"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "us-east-1" # This is the region where we are going to create our resources.
  
}