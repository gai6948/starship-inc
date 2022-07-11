variable "kubernetes_version" {
  default     = "1.21"
  description = "Kubernetes version to use (x.xx)"
}

variable "aws_region" {
  default     = "us-west-2"
  description = "Region to deploy to"
  type        = string
}
