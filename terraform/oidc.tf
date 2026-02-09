# 1. Define the OIDC Provider for GitHub
# Fetch GitHub's OIDC certificate dynamically
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# 2. Create the Role that GitHub Actions will assume
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-devsecops-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Condition = {
            StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            }  
          StringLike = {
            # STRICT SECURITY: Replace 'YourOrg/YourRepo' with your actual repo
            "token.actions.githubusercontent.com:sub": "repo:H11iye/Self-Healing-Secure-Software-Factory-:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

# 3. Attach Permissions (For now, PowerUser or specific EKS/VPC access)
resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}