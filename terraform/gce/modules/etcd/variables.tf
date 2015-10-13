# variable "" {}
#etcd
variable "etcd_count" {}
variable "etcd_image" {}
variable "etcd_machine_type" {}
variable "etcd_data_disk_size" {}
variable "etcd_image_disk_size" {}

# vars from modules
variable "network_name" {}
variable "ip" {}

# gce variables
variable "gce_project" {}
variable "gce_zone" {}
variable "gce_region" {}
variable "gce_account_file" {}
variable "gce_cluster_name" {}
variable "gce_sshkey_metadata" {}
variable "gce_network_range" {}

# flannel
variable "flannel_network" {}
