output "ecr_repository_url" {
  description = "Paste this into GitHub secret AWS_ECR_REGISTRY or use in CI"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "ecs_task_public_ip" {
  description = "After service is running, find task public IP in ECS console or via CLI"
  value       = "aws ecs list-tasks --cluster ${aws_ecs_cluster.main.name} --region ${var.aws_region}"
}
