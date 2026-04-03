# ===== Terraform Backend Configuration =====
#
# CHOOSE ONE: Uncomment and configure based on your cloud provider
#
# ===== OPTION 1: AWS S3 Backend =====
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"  # CHANGE THIS
#     key            = "static-app/terraform.tfstate"
#     region         = "eu-west-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }
#
# Setup Steps:
# 1. Create S3 bucket:
#    aws s3 mb s3://your-terraform-state-bucket --region eu-west-1
#
# 2. Enable versioning:
#    aws s3api put-bucket-versioning \
#      --bucket your-terraform-state-bucket \
#      --versioning-configuration Status=Enabled
#
# 3. Create DynamoDB table:
#    aws dynamodb create-table \
#      --table-name terraform-locks \
#      --attribute-definitions AttributeName=LockID,AttributeType=S \
#      --key-schema AttributeName=LockID,KeyType=HASH \
#      --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
#
# 4. Initialize backend:
#    terraform init \
#      -backend-config="key=static-app/terraform.tfstate" \
#      -backend-config="bucket=your-terraform-state-bucket"
#

# ===== OPTION 2: Azure Storage Backend =====
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "terraform-rg"
#     storage_account_name = "tfstatestorage"
#     container_name       = "tfstate"
#     key                  = "static-app/terraform.tfstate"
#   }
# }
#
# Setup Steps:
# 1. Create resource group:
#    az group create --name terraform-rg --location westeurope
#
# 2. Create storage account:
#    az storage account create \
#      --resource-group terraform-rg \
#      --name tfstatestorage \
#      --sku Standard_LRS
#
# 3. Create blob container:
#    az storage container create \
#      --account-name tfstatestorage \
#      --name tfstate
#
# 4. Get storage account key:
#    az storage account keys list \
#      --resource-group terraform-rg \
#      --account-name tfstatestorage
#
# 5. Initialize backend:
#    terraform init \
#      -backend-config="resource_group_name=terraform-rg" \
#      -backend-config="storage_account_name=tfstatestorage" \
#      -backend-config="container_name=tfstate" \
#      -backend-config="key=static-app/terraform.tfstate" \
#      -backend-config="access_key=<YOUR_ACCESS_KEY>"
#

# ===== OPTION 3: Local Backend (Development Only) =====
# Default behavior - state stored locally in terraform.tfstate
# Not recommended for production or team environments
