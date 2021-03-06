#variable "etcd_address" {}

variable "domain" {}
variable "domain_zone_name" {}
variable "cert_passphrase" {}

variable "etcd_address" {}
variable "lb_ip" {}
variable "service_network_name" {}

variable "api_user" {}
variable "api_pass" {}

variable "kube_image" {}
variable "km_disk_size" {}
variable "km_machine_type" {}
variable "km_count" {}

  #gce vars
variable "gce_project" {}
variable "gce_region" {}
variable "gce_zone" {}
variable "cluster_prefix" {}
variable "gce_account_file" {}
#removeable?
variable "gce_network_range" {}

  # flannel
variable "flannel_network" {}
