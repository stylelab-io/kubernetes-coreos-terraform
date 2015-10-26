#variable "etcd_address" {}

variable "domain" {}
variable "cert_passphrase" {}

variable "etcd_address" {}
variable "lb_ip" {}
variable "network_name" {}
variable "kube_image" {}

variable "km_count" {}

  #gce vars
variable "gce_project" {}
variable "gce_region" {}
variable "gce_zone" {}
variable "cluster_prefix" {}
variable "gce_account_file" {}
variable "gce_network_range" {}

  # flannel
variable "flannel_network" {}
