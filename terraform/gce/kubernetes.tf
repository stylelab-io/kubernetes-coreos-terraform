provider "google" {
    account_file = "${file("${var.gce_account_file}")}"
    project = "${var.gce_project}"
    region = "${var.gce_region}"
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

module "cert" {
    source = "./modules/cert"

    etcd_cert_path = "${var.etcd_cert_path}"
    etcd_cert_passphrase = "${var.etcd_cert_passphrase}"
}

module "etcd" {
    source = "modules/etcd"

    # provided by modules
    ip ="${module.network.etcd_ip}"
    network_name = "${module.network.network_name}"

    # etcd vars
    etcd_count = "${var.etcd_count}"
    etcd_image = "${var.image}"
    etcd_data_disk_size = "${var.etcd_data_disk_size}"
    etcd_image_disk_size = "${var.etcd_image_disk_size}"
    etcd_machine_type = "${var.etcd_machine_type}"

    #gce vars
    gce_project = "${var.gce_project}"
    gce_region = "${var.gce_region}"
    gce_zone = "${var.gce_zone}"
    gce_cluster_name = "${var.gce_cluster_name}"
    gce_sshkey_metadata = "${var.gce_sshkey_metadata}"
    gce_account_file = "${var.gce_account_file}"
    gce_network_range = "${var.gce_network_range}"

    # flannel
    flannel_network = "${var.flannel_network}"
}


module "kubernetes-master" {
    source = "modules/kubernetes-master"

    etcd_address = "${module.etcd.pub_address}"
    ip ="${module.network.km_ip}"
    network_name = "${module.network.network_name}"

    kube_image = "${var.image}"
    km_count = "${var.km_count}"

    #gce vars
    gce_project = "${var.gce_project}"
    gce_region = "${var.gce_region}"
    gce_zone = "${var.gce_zone}"
    gce_cluster_name = "${var.gce_cluster_name}"
    gce_sshkey_metadata = "${var.gce_sshkey_metadata}"
    gce_account_file = "${var.gce_account_file}"
    gce_network_range = "${var.gce_network_range}"

    # flannel
    flannel_network = "${var.flannel_network}"

}
/*
module "kubernetes-node" {
    source = "modules/kubernetes-node"
}*/
