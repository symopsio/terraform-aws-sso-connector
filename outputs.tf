data "aws_region" "current" {}

output "settings" {
  description = "A map of settings to supply to a Sym Permission Context."
  value = {
    cloud        = "aws"
    instance_arn = local.instance_arn
    region       = data.aws_region.current.name
    role_arn     = aws_iam_role.this.arn
  }
}
