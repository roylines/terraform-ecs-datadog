variable "name" {
  description = "the container name"
  default = "datadog"
}

variable "vpc" {
  description = "the vpc name"
}

variable "cluster_id" {
  description = "the cluster_id"
}

variable "desired_count" {
  description = "the number of microservices to provision"
}

variable "api_key" {
  description = "datadog api key"
}
