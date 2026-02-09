resource "aws_eks_cluster" "main" {
  name     = "secure-factory-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.31" # Use the latest stable version

  vpc_config {
    subnet_ids              = module.vpc.private_subnets
    endpoint_private_access = true
    endpoint_public_access  = true # Set to false later for extreme security
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# IAM Role for the EKS Cluster itself
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-factory-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}