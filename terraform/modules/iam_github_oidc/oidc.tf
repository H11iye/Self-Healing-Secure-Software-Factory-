# 1. GitHub OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "2b18947a6a9fc7764fd8b5fb18a863b0c6dac24f"
  ]
}

# 2. IAM Role for GitHub Actions (PROD SAFE)
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-prod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Self-Healing-Secure-Software-Factory-:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

# 3. Least-Privilege policy (example placeholder)
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
