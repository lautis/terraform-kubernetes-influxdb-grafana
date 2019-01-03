provider "influxdb" {
  url      = "https://${var.influxdb_host}"
  username = "${var.influxdb_username}"
  password = "${var.influxdb_password}"
}

resource "kubernetes_namespace" "influxdb" {
  metadata {
    name = "influxdb"
  }
}

resource "helm_release" "influxdb" {
  name      = "influxdb"
  chart     = "influx/influxdb"
  namespace = "${kubernetes_namespace.influxdb.id}"

  set {
    name  = "persistence.enabled"
    value = true
  }

  set {
    name  = "persistence.storageClass"
    value = "do-block-storage"
  }
}

data "external" "auth" {
  program = [
    "./auth-secret.sh",
    "#T(#IS-ZJDV5V5*Ceea17ZLMmZiX6EjTU1l_8%(v",
    "${var.influxdb_username}",
    "${var.influxdb_password})",
  ]
}

resource "helm_release" "influxdb-ingress" {
  name      = "influxdb-ingress"
  chart     = "./charts/influxdb-ingress"
  namespace = "${kubernetes_namespace.influxdb.id}"

  depends_on = [
    "helm_release.ingress",
  ]

  set {
    name  = "ingress.host"
    value = "${var.influxdb_host}"
  }

  set {
    name  = "auth"
    value = "${data.external.auth.result.value}"
  }
}

resource "influxdb_database" "ruuvi" {
  name = "ruuvi"

  depends_on = ["helm_release.influxdb-ingress"]
}
