provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_tag" "kubernetes" {
  name = "kubernetes"
}

resource "digitalocean_kubernetes_cluster" "tick" {
  name    = "tick-cluster-1"
  region  = "fra1"
  version = "1.13.1-do.2"

  node_pool {
    name       = "kubernetes-worker"
    size       = "s-1vcpu-2gb"
    node_count = 1
    tags       = ["${digitalocean_tag.kubernetes.id}"]
  }
}

provider "kubernetes" {
  host = "${digitalocean_kubernetes_cluster.tick.endpoint}"

  client_certificate     = "${base64decode(digitalocean_kubernetes_cluster.tick.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(digitalocean_kubernetes_cluster.tick.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(digitalocean_kubernetes_cluster.tick.kube_config.0.cluster_ca_certificate)}"
}

resource "kubernetes_service_account" "tiller" {
  automount_service_account_token = true

  metadata {
    name      = "tiller-service-account"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller-cluster-rule"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.tiller.metadata.0.name}"
    api_group = ""
    namespace = "${kubernetes_service_account.tiller.metadata.0.namespace}"
  }

  provisioner "local-exec" {
    command = "helm init --client-only"
  }
}

provider "helm" {
  install_tiller  = true
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.12.1"
  max_history     = 10

  kubernetes {
    host                   = "${digitalocean_kubernetes_cluster.tick.endpoint}"
    client_certificate     = "${base64decode(digitalocean_kubernetes_cluster.tick.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(digitalocean_kubernetes_cluster.tick.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(digitalocean_kubernetes_cluster.tick.kube_config.0.cluster_ca_certificate)}"
  }
}

resource "helm_repository" "influx" {
  name = "influx"
  url  = "http://influx-charts.storage.googleapis.com"
}

resource "helm_release" "ingress" {
  name      = "ingress"
  chart     = "stable/nginx-ingress"
  namespace = "kube-system"
}

data "kubernetes_service" "ingress" {
  metadata {
    name      = "ingress-nginx-ingress-controller"
    namespace = "kube-system"
  }

  depends_on = [
    "helm_release.ingress",
  ]
}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "prometheus-operator" {
  name      = "prometheus-operator"
  chart     = "stable/prometheus-operator"
  namespace = "${kubernetes_namespace.prometheus.id}"
}
