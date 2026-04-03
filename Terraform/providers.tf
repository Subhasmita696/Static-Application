terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # ===== UNCOMMENT WHEN READY =====
  # For AWS: Creates S3 bucket first with: aws s3 mb s3://your-terraform-state-bucket
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "static-app/terraform.tfstate"
  #   region         = "eu-west-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }

  # For Azure: Create storage account & container manually
  # backend "azurerm" {
  #   resource_group_name  = "terraform-rg"
  #   storage_account_name = "tfstatestorage"
  #   container_name       = "tfstate"
  #   key                  = "static-app/terraform.tfstate"
  # }
}

# ===== AWS PROVIDER =====
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "static-app"
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    }
  }
}

# ===== AZURE PROVIDER =====
provider "azurerm" {
  features {
    kubernetes_cluster {
      flush_http_proxy_on_update = true
    }
  }

  skip_provider_registration = false
}