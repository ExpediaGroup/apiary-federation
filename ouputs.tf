output "waggle_dance_load_balancers" {
  value = kubernetes_service.waggle_dance[0].load_balancer_ingress.*.hostname
}
