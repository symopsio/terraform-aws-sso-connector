variable "environment" {
  description = "An environment qualifier for the resources this module creates, to support a Terraform SDLC."
  type        = string
}

variable "runtime_role_arns" {
  description = "ARNs of the runtime connector roles that are trusted to assume the SSO role."
  type        = list(string)
}

variable "sso_account_assignment_enabled" {
  description = "Whether to allow Sym to assign permission sets to the same account where the SSO instance is provisioned"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
