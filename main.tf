data "aws_ssoadmin_instances" "this" {}
data "aws_caller_identity" "current" {}

locals {
  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
}

resource "aws_iam_role" "this" {
  name = "SymSSO${title(var.environment)}"
  path = "/sym/"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        AWS = var.runtime_role_arns
      }
    }]
    Version = "2012-10-17"
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "sso" {
  policy_arn = aws_iam_policy.sso.arn
  role       = aws_iam_role.this.name
}

resource "aws_iam_policy" "sso" {
  name = "SymSSO${title(var.environment)}"
  path = "/sym/"

  description = "Allows Sym to manage SSO Permission Set escalations"
  tags        = var.tags
  policy      = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sso:CreateAccountAssignment",
                "sso:DeleteAccountAssignment",
                "sso:Describe*",
                "sso:List*",
                "identitystore:ListUsers"
            ],
            "Resource": "*"
        }
    ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "sso_groups" {
  policy_arn = aws_iam_policy.sso_groups.arn
  role       = aws_iam_role.this.name
}

resource "aws_iam_policy" "sso_groups" {
  name = "SymSSOGroup${title(var.environment)}"
  path = "/sym/"

  description = "Allows Sym to manage SSO Group escalations"
  tags        = var.tags
  policy      = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "identitystore:CreateGroupMembership",
        "identitystore:DeleteGroupMembership",
        "identitystore:Describe*",
        "identitystore:Get*",
        "identitystore:IsMemberInGroups",
        "identitystore:List*"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "list_accounts" {
  policy_arn = aws_iam_policy.list_accounts.arn
  role       = aws_iam_role.this.name
}

resource "aws_iam_policy" "list_accounts" {
  name = "SymListAccounts${title(var.environment)}"
  path = "/sym/"

  description = "Allows Sym to List Accounts in the AWS Organization"
  tags        = var.tags
  policy      = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "organizations:ListAccounts",
        "organizations:ListAccountsForParent"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "account" {
  count = var.sso_account_assignment_enabled ? 1 : 0

  policy_arn = aws_iam_policy.account[0].arn
  role       = aws_iam_role.this.name
}

resource "aws_iam_policy" "account" {
  count = var.sso_account_assignment_enabled ? 1 : 0

  name = "SymSSO${title(var.environment)}-Account"
  path = "/sym/"

  description = "Additional permissions that allow Sym to assign permissions in the same AWS account as the SSO instance itself"
  tags        = var.tags
  policy      = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetSAMLProvider",
                "iam:UpdateSAMLProvider"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:AttachRolePolicy",
                "iam:CreateRole",
                "iam:GetRole",
                "iam:ListAttachedRolePolicies",
                "iam:ListRolePolicies",
                "iam:UpdateRole"
            ],
            "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/*"
        }
    ]
}
EOT
}
