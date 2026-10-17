variable "region" {
  description = "AWS region for the example"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Required tags for the example resources"
  type = map(string)
  default = {
    environment = "dev"
    managed_by  = "terraform"
    owner       = "platform-team"
  }
}
