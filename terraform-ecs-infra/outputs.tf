output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "alb_dns_name" {
  description = "Hit this URL to test the app — http://<this-value>/"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "Pass this to Project 5 WAF to attach protection to this ALB"
  value       = aws_lb.main.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}
