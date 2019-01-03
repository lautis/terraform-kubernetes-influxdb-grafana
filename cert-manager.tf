resource "helm_release" "cert-manager" {
  name      = "cert-manager"
  chart     = "stable/cert-manager"
  namespace = "kube-system"

  set {
    name  = "createCustomResource"
    value = "true"
  }
}

resource "helm_release" "cluster-issuer" {
  name      = "cluster-issuer"
  chart     = "./charts/cluster-issuer"
  namespace = "kube-system"

  depends_on = [
    "helm_release.cert-manager",
  ]

  set {
    name  = "email"
    value = "${var.letsencrypt_email}"
  }
}
