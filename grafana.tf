resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"
  }
}

data "template_file" "grafana_values" {
  template = "${file("./templates/grafana-values.yml")}"

  vars {
    host           = "${var.grafana_host}"
    admin_password = "${var.grafana_admin_password}"
  }
}

resource "helm_release" "grafana" {
  name      = "grafana"
  chart     = "stable/grafana"
  namespace = "${kubernetes_namespace.grafana.id}"

  values = [
    "${data.template_file.grafana_values.rendered}",
  ]
}
