output "load balancer IP address" {
  value = "${data.kubernetes_service.ingress.load_balancer_ingress.0.ip}"
}
