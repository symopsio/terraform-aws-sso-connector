# sso-connector

The `sso-connector` module provisions an IAM role that the [AWS SSO Strategy](https://docs.symops.com/docs/aws-sso) can use to escalate or de-escalate users in SSO Instances.

This `Connector` will provision a single IAM role for the Sym Runtime to use with a Strategy.

Only the supplied `runtime_role_arns` are trusted to assume this role.

```hcl
module "sso_connector" {
  source  = "symopsio/sso-connector/sym"
  version = ">= 1.0.0"

  environment = "sandbox"
  runtime_role_arns = [ var.runtime_role_arn ]
}
```
