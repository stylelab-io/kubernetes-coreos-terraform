#variable "etcd_address" {}

variable "domain" {}
variable "domain_zone_name" {}
variable "cert_passphrase" {}

variable "etcd_address" {}
variable "lb_ip" {}
variable "service_network_name" {}
variable "kube_image" {}

variable "kn_count" {}
variable "kn_machine_type" {}

varibale "kn_scale_min_count" {}
varibale "kn_scale_max_count" {}
varibale "kn_scale_cpu_target" {}
variable "kn_scale_cooldown" {}

  #gce vars
variable "gce_project" {}
variable "gce_region" {}
variable "gce_zone" {}
variable "cluster_prefix" {}
variable "gce_account_file" {}
# removable?
variable "gce_network_range" {}

  # flannel
variable "flannel_network" {}
