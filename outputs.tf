output "service_name" {
  description = "Service name for Terraboard deployment"
  value       = kubernetes_service.terraboard.metadata.0.name
}

output "service_port" {
  description = "Port exposed by the service"
  value       = kubernetes_service.terraboard.spec.0.port.0.name
}
