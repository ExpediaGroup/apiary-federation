output "waggle_dance_load_balancers" {
  value = var.wd_instance_type == "k8s" ? kubernetes_service.waggle_dance[0].load_balancer_ingress.*.hostname : (var.wd_instance_type == "ecs" && var.enable_autoscaling ? [aws_lb.waggledance[0].dns_name] : [])
}

output "datadog_api_key" {
  value = jsondecode(data.aws_secretsmanager_secret_version.datadog_key.secret_string).api_key
}

output "datadog_app_key" {
  value = jsondecode(data.aws_secretsmanager_secret_version.datadog_key.secret_string).app_key
}