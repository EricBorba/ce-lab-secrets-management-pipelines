variable "project_name" {
  description = "Project identifier"
  type        = string
  default     = "m508-secrets-lab"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "secret_rotation_days" {
  description = "Number of days before a secret is considered stale"
  type        = number
  default     = 90
}
