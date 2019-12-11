output "waggle_dance_load_balancers" {
  value = var.wd_instance_type == "k8s" ? kubernetes_service.waggle_dance[0].load_balancer_ingress.*.hostname : ""
}
