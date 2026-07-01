variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "app_name" {
  description = "Used for ECR repo name, container name, and resource tags"
  type        = string
  default     = "demo-app"
}

variable "ecs_cluster_name" {
  type    = string
  default = "demo-cluster"
}

variable "ecs_service_name" {
  description = "Also used as the ECS task definition family name"
  type        = string
  default     = "demo-app-service"
}
