# ===== Global Variables =====
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "static-app"
}

# ===== AWS Variables =====
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "vpc_id" {
  description = "VPC ID - Get from: aws ec2 describe-vpcs"
  type        = string
  default     = ""  # CONFIGURE: Set to your VPC ID
}

variable "subnet_ids" {
  description = "Subnet IDs for EKS - Get from: aws ec2 describe-subnets"
  type        = list(string)
  default     = []  # CONFIGURE: Set to your subnet IDs

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnets are required for EKS."
  }
}

variable "eks_node_instance_types" {
  description = "EC2 instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_desired_size" {
  description = "Desired number of EKS nodes"
  type        = number
  default     = 2

  validation {
    condition     = var.eks_desired_size >= 1 && var.eks_desired_size <= 10
    error_message = "Desired size must be between 1 and 10."
  }
}

variable "eks_min_size" {
  description = "Minimum number of EKS nodes"
  type        = number
  default     = 2
}

variable "eks_max_size" {
  description = "Maximum number of EKS nodes"
  type        = number
  default     = 5
}

# ===== Azure Variables =====
variable "azure_location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = ""  # CONFIGURE: Set your subscription ID
}

variable "aks_node_count" {
  description = "Initial number of AKS nodes"
  type        = number
  default     = 2

  validation {
    condition     = var.aks_node_count >= 1 && var.aks_node_count <= 10
    error_message = "Node count must be between 1 and 10."
  }
}

variable "aks_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"  # More cost-effective than DS2_v2
}

variable "aks_kubernetes_version" {
  description = "Kubernetes version for AKS"
  type        = string
  default     = "1.29"
}

# ===== Tagging Variables =====
variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "static-app"
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}