# variable "" {}

variable "image" {}
variable "cluster_prefix" {
    default = "test-"
}

variable "api_user" {}
variable "api_pass" {}

variable "domain" {}
variable "domain_zone_name" {}

# gce variables
variable "gce_project" {}
variable "gce_account_file" {}

variable "gce_zone" {
    default = "europe-west1-b"
}
variable "gce_region" {
    default = "europe-west1"
}

# network
variable "gce_service_network_name" {
    default = "kube-service"
}
variable "gce_service_network_range" {
    default ="10.220.0.0/16"
}
variable "gce_pod_network_name" {
    default = "kube-pod"
}
variable "gce_pod_network_range" {
    default ="10.230.0.0/16"
}

# certs
variable "cert_passphrase" {
    default = ""
}
variable "cert_path" {
    default = "../../cert-files"
}

# flannel
variable "flannel_network" {
    default = "10.230.0.0/16"
}

# etcd
variable "etcd_machine_type" {
    default = "n1-standard-1"
}
variable "etcd_count" {
    default = 3
}
variable "etcd_data_disk_size" {
    default = 100
}
variable "etcd_image_disk_size" {
    default = 100
}

# kube master
variable "km_machine_type" {
    default = "n1-standard-1"
}
variable "km_disk_size" {
    default = 100
}
variable "km_count" {
    default = 1
}
# kube node
variable "kn_machine_type" {
    default = "n1-standard-1"
}
variable "kn_disk_size" {
    default = 200
}
variable "kn_image" {
    default = "coreos-stable-766-3-0-v20150908"
}
variable "kn_count" {
    default = 1
}
variable "kn_scale_min_count" {
    default = 1
}
variable "kn_scale_max_count" {
    default = 1
}
variable "kn_scale_cooldown" {
    default = 120
}
variable "kn_scale_cpu_target" {
    default = 0.8
}
