# variable "" {}

variable "image" {}

# gce variables
variable "gce_project" {}
variable "gce_sshkey_metadata" {}
variable "gce_account_file" {}

variable "gce_zone" {
    default = "europe-west1-b"
}
variable "gce_region" {
    default = "europe-west1"
}
variable "gce_cluster_name" {
    default = "ha-kube"
}
variable "gce_network_name" {
    default = "default"
}

variable "gce_network_range" {
    default ="10.10.0.0/16"
}

# flannel
variable "flannel_network" {
    default = "10.40.0.0/16"
}

# etcd
# must be set for each deployment =(
variable "etcd_discovery_url" {}

variable "etcd_machine_type" {
    default = "n1-standard-1"
}
variable "etcd_count" {
    default = 1
}
variable "etcd_data_disk_size" {
    default = 100
}
variable "etcd_image_disk_size" {
    default = 100
}

# kubernetes
variable "km_machine_type" {
    default = "n1-standard-1"
}
variable "km_disk_size" {
    default = 50
}
variable "km_count" {
    default = 1
}
variable "km_image" {}

variable "kw_machine_type" {
    default = "n1-standard-1"
}
variable "kw_disk_size" {
    default = 30
}
variable "kw_image" {
    default = "coreos-stable-766-3-0-v20150908"
}
variable "kw_count" {
    default = 1
}
