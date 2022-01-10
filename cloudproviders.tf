##---------------------------------- Setting up the Terraform environment
terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.70.0"
    }
  }

  cloud {
    organization = "MyTFCloud"

    workspaces {
      name = "myAWSworkspaZ"
    }
  }
}

##---------------------------------- Configure the providers - The main provider doesn't contains an alias meta-argument
provider "aws" {
  region     = "us-east-1"
  access_key = var.access-key-id
  secret_key = var.secret-key
}

provider "aws" {
  alias      = "africa"
  region     = "af-south-1"
  access_key = var.access-key-id
  secret_key = var.secret-key
}

provider "aws" {
  alias      = "canada"
  region     = "ca-central-1"
  access_key = var.access-key-id
  secret_key = var.secret-key
}
