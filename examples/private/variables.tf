variable "region" {
  description = "AWS region for the example"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Required tags for the example resources"
  type = object({
    environment = string
    managed_by  = string
    owner       = string
  })
  default = {
    environment = "dev"
    managed_by  = "terraform"
    owner       = "platform-team"
  }
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Existing private subnet IDs in the selected VPC"
  type        = set(string)
}

variable "vpc_cidr" {
  description = "IPv4 VPC CIDR permitted for outbound HTTPS"
  type        = string
}
