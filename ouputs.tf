output "waggle_dance_load_balancers" {
  count = var.wd_instance_type == "k8s" ? 1 : 0
  value = kubernetes_service.waggle_dance[0].load_balancer_ingress.*.hostname
}
