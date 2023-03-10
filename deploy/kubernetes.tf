data "kubectl_path_documents" "manifests" {
  pattern = "${path.module}/manifests/*.yml"
  vars = {
    db_user     = var.db_user
    db_password = var.db_password
  }
}

resource "kubectl_manifest" "deploy" {
  for_each  = toset(data.kubectl_path_documents.manifests.documents)
  yaml_body = each.value
}

resource "kubernetes_namespace" "namespaces" {
  for_each = var.namespaces
  metadata {
    name = each.value
  }
}

data "kubernetes_service_v1" "lb" {
  depends_on = [kubectl_manifest.deploy]
  metadata {
    name      = "app-service"
    namespace = "profilr"
  }
}
