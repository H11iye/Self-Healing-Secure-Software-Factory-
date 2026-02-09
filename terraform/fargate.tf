resource "aws_eks_fargate_profile" "main" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "fp-default"
  pod_execution_role_arn = aws_iam_role.fargate_pod_role.arn
  subnet_ids             = module.vpc.private_subnets

  # This profile will pick up any pod in the 'default' or 'app' namespace
  selector { namespace = "default" }
  selector { namespace = "app" }
}

# IAM Role for Fargate Pods (Execution Role)
resource "aws_iam_role" "fargate_pod_role" {
  name = "eks-fargate-pod-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks-fargate-pods.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "fargate_pod_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_pod_role.name
}