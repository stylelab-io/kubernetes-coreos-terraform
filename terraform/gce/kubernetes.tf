provider "google" {
    account_file = "${file("/Users/stevenwirges/google/stylelounge-1042.json")}"
    project = "stylelounge-1042"
    region = "europe-west1"
}

module "network" {
    source = "./modules/network"

    km_count = "${var.km_count}"

    gce_project = "${var.gce_project}"
    gce_region = "${var.gce_region}"
    gce_zone = "${var.gce_zone}"
    gce_cluster_name = "${var.gce_cluster_name}"
    gce_sshkey_metadata = "${var.gce_sshkey_metadata}"
    gce_account_file = "${var.gce_account_file}"
    gce_network_name = "${var.gce_network_name}"
    gce_network_range = "${var.gce_network_range}"
}
/*
module "etcd" {
    source = "modules/etcd"

    etcd_count = "${var.etcd_count}"
  #  etcd_discovery_url = "${var.etcd_discovery_url}"
  #  etcd_image = "${var.etcd_image}"
    etcd_data_disk_size = "${var.etcd_data_disk_size}"
    etcd_image_disk_size = "${var.etcd_image_disk_size}"
    etcd_machine_type = "${var.etcd_machine_type}"

    ip ="${module.network.etcd_ips}"
    network_name = "${var.gce_network_name}"



    gce_project = "${var.gce_project}"
    gce_region = "${var.gce_region}"
    gce_zone = "${var.gce_zone}"
    gce_cluster_name = "${var.gce_cluster_name}"
    gce_sshkey_metadata = "${var.gce_sshkey_metadata}"
    gce_account_file = "${var.gce_account_file}"
}*/



/*resource "execute_command" "commands" {
  command = "touch testfile"
  destroy_command = "rm testfile"
}*/


module "kubernetes-master" {
    source = "modules/kubernetes-master"

  #  etcd_address = "${module.etcd.pub_address}"
}
/*
module "kubernetes-node" {
    source = "modules/kubernetes-node"
}*/
