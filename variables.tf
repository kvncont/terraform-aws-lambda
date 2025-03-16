variable "region" {
  type        = string
  description = "AWS Region"
}

variable "assume_role_arn" {
  type        = string
  description = "ARN Role that Terraform assume"
}

variable "waypoint_application" {
  type        = string
  description = "Name of the application"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.waypoint_application))
    error_message = "The waypoint_application variable must start with a lowercase letter and can only contain lowercase letters, numbers, and hyphens (-)."
  }
}

variable "runtime" {
  type        = string
  description = "Runtime environment for the Lambda function"
  validation {
    condition     = can(regex("^(python3\\.(10|11|12|13)|nodejs(20|22)\\.x)$", var.runtime))
    error_message = "The runtime variable must be one of the following: python3.10, python3.11, python3.12, python3.13, nodejs20.x, or nodejs22.x."
  }
}