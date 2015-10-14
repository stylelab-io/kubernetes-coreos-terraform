#variable "etcd_address" {}

variable "etcd_address" {}
variable "ip" {}
variable "network_name" {}
variable "kube_image" {}

variable "km_count" {}

  #gce vars
variable "gce_project" {}
variable "gce_region" {}
variable "gce_zone" {}
variable "cluster_prefix" {}
variable "gce_sshkey_metadata" {}
variable "gce_account_file" {}
variable "gce_network_range" {}

  # flannel
variable "flannel_network" {}
