# ===== AWS EKS Outputs =====

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = try(module.eks.cluster_name, "")
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = try(module.eks.cluster_arn, "")
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = try(module.eks.cluster_endpoint, "")
}

output "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  value       = try(module.eks.cluster_version, "")
}

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = try(module.eks.cluster_security_group_id, "")
}

output "eks_managed_node_groups" {
  description = "EKS managed node group details"
  value = try({
    for name, group in module.eks.eks_managed_node_groups : name => {
      id                 = group.id
      asg_name           = group.asg_name
      iam_role_arn       = group.iam_role_arn
    }
  }, {})
}

# ===== Configure kubectl =====
output "eks_configure_kubectl" {
  description = "Command to configure kubectl for EKS"
  value       = "aws eks update-kubeconfig --name ${try(module.eks.cluster_name, "")} --region ${var.aws_region}"
}

# ===== KMS Key =====
output "eks_kms_key_id" {
  description = "KMS key ID used for EKS encryption"
  value       = aws_kms_key.eks.key_id
}