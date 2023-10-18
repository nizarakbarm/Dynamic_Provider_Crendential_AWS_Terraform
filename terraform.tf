terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.21.0"
    }
  }
}

provider "aws" {
  # Configuration options
  alias = "Singapore"
  region = "ap-southeast-1"
  #sts_region = "ap-southeast-1"
}