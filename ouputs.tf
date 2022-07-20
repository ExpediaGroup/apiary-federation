output "waggle_dance_load_balancers" {
  value = var.wd_instance_type == "k8s" ? kubernetes_service.waggle_dance[0].load_balancer_ingress.*.hostname : (var.wd_instance_type == "ecs" && var.enable_autoscaling ? [aws_lb.waggledance[0].dns_name] : [])
}
