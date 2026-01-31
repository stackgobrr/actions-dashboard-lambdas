variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'"
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "actions-dashboard"
}