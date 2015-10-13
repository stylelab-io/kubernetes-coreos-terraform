#variable "etcd_address" {}

variable "etcd_address" {}
variable "ip" {}
variable "network_name" {}
variable "kube_image" {}

  #gce vars
variable "gce_project" {}
variable "gce_region" {}
variable "gce_zone" {}
variable "gce_cluster_name" {}
variable "gce_sshkey_metadata" {}
variable "gce_account_file" {}
variable "gce_network_range" {}

  # flannel
variable "flannel_network" {}
