variable "namespace" {
  description = "Namespace where Gose is deployed"
  type        = string
  default     = "default"
}

variable "image_registry" {
  description = "Image registry, e.g. gcr.io, docker.io"
  type        = string
  default     = "ghcr.io"
}

variable "image_repository" {
  description = "Image to start for this pod"
  type        = string
  default     = "stv0g/gose"
}

variable "image_tag" {
  description = "Image tag to use"
  type        = string
  default     = "latest"
}

variable "container_name" {
  description = "Name of the Gose container"
  type        = string
  default     = "gose"
}

variable "match_labels" {
  description = "Match labels to add to the Gose deployment, will be merged with labels"
  type        = map(any)
  default     = {}
}

variable "labels" {
  description = "Labels to add to the Gose deployment"
  type        = map(any)
  default     = {}
}

variable "host" {
  description = "Public facing hostname for Gose"
  type        = string
  default     = "http://localhost:8080"
}

variable "config" {
  description = "Gose config"
  type = object({
    listen          = optional(string)
    base_url        = optional(string)
    static          = optional(string)
    max_upload_size = optional(string)
    servers = optional(list(object({
      bucket          = string
      endpoint        = string
      region          = string
      path_style      = optional(string)
      no_ssl          = optional(string)
      access_key      = string
      secret_key      = string
      max_upload_size = optional(string)
      part_size       = optional(string)
      setup = optional(object({
        bucket                   = optional(bool)
        cors                     = optional(bool)
        lifecycle                = optional(bool)
        abort_incomplete_uploads = optional(number)
      }))
    })))
    expiration = optional(list(object({
      id    = string
      title = string
      days  = number
    })))
    shortener = optional(object({
      endpoint = string
      method   = string
      response = string
    }))
    notification = optional(object({
      urls     = list(string)
      template = string
      mail = object({
        url      = string
        template = string
      })
    }))
  })
}

variable "service_name" {
  description = "Name of service to deploy"
  type        = string
  default     = "gose"
}

variable "service_type" {
  description = "Type of service to deploy"
  type        = string
  default     = "ClusterIP"
}
