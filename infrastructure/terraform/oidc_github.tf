# GitHub OIDC provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = var.github_oidc_thumbprint
}

# IAM role for GitHub Actions
data "aws_iam_policy_document" "github_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = ["repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/${var.github_branch}"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# GitHub deployment role
resource "aws_iam_role" "github_deploy_role" {
  name               = "github-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role_policy.json

    tags = {
        "Project" = "ResumeWebsite"
    }
}


# Least-privilege policy: S3 sync and cloudfront invalidation
data "aws_iam_policy_document" "github_deploy_policy" {
  statement {
    effect = "Allow"
    actions = ["s3:ListBucket"]
    resources = [aws_s3_bucket.resume_bucket.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      "${aws_s3_bucket.resume_bucket.arn}/*",
       aws_s3_bucket.resume_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_deploy_policy_inline" {
  name   = "github-deploy-policy"
  policy = data.aws_iam_policy_document.github_deploy_policy.json
}