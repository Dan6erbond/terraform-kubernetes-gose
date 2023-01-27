terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
  }
}

locals {
  match_labels = merge({
    "app.kubernetes.io/name"     = "gose"
    "app.kubernetes.io/instance" = "gose"
  }, var.match_labels)
  labels = merge(local.match_labels, var.labels)
  config = merge(var.config, {
    "listen"   = ":8080",
    "base_url" = var.host
  })
}

resource "kubernetes_deployment" "gose" {
  metadata {
    name      = "gose"
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    replicas = 1
    selector {
      match_labels = local.labels
    }
    template {
      metadata {
        labels = local.labels
        annotations = {
          "ravianand.me/config-hash" = sha1(jsonencode(merge(
            kubernetes_secret.gose.data
          )))
        }
      }
      spec {
        container {
          image = var.image_registry == "" ? "${var.image_repository}:${var.image_tag}" : "${var.image_registry}/${var.image_repository}:${var.image_tag}"
          name  = var.container_name
          args  = ["-config", "/config.yaml"]
          port {
            name           = "http"
            container_port = 8080
          }
          volume_mount {
            name       = "config"
            mount_path = "/config.yaml"
            sub_path   = "config.yaml"
          }
        }
        volume {
          name = "config"
          secret {
            secret_name = kubernetes_service.gose.metadata.0.name
            items {
              key  = "config.yaml"
              path = "config.yaml"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "gose" {
  metadata {
    name      = var.service_name
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    type     = var.service_type
    selector = local.match_labels
    port {
      name        = "http"
      port        = 8080
      target_port = "http"
    }
  }
}

resource "kubernetes_secret" "gose" {
  metadata {
    name      = "gose"
    namespace = var.namespace
  }
  data = {
    "config.yaml" = yamlencode(local.config)
  }
}
