provider "google" {
    account_file  = "${file("${var.gce_account_file}")}"
    project       = "${var.gce_project}"
    region        = "${var.gce_region}"
}

output "1_kubernetes_api_url" {
    value = "${module.kubernetes-master.kubernetes_api_url}"
}

output "2_help" {
  value = "Excute the following commands to add this cluster to your kubernetes configuration:"
}

output "3_command" {
  value = "kubectl config set-cluster ${var.domain_zone_name} --insecure-skip-tls-verify=true --server=${module.kubernetes-master.kubernetes_api_url}"
}

output "4_command" {
  value = "kubectl config set-credentials ${var.domain_zone_name} --password='${var.api_pass}' --username='${var.api_user}'"
}

output "5_command" {
  value = "kubectl config set-context hakoc --cluster=${var.domain_zone_name} --user=${var.domain_zone_name} --namespace=default"
}

output "6_command" {
  value = "kubectl config set-context ${var.domain_zone_name}"
}

module "network" {
    source                    = "./modules/network"

    gce_project               = "${var.gce_project}"
    gce_region                = "${var.gce_region}"
    gce_zone                  = "${var.gce_zone}"
    cluster_prefix            = "${var.cluster_prefix}"
    gce_account_file          = "${var.gce_account_file}"
    gce_service_network_name  = "${var.gce_service_network_name}"
    gce_service_network_range = "${var.gce_service_network_range}"
    gce_pod_network_name      = "${var.gce_pod_network_name}"
    gce_pod_network_range     = "${var.gce_pod_network_range}"
}

module "cert" {
    source            = "./modules/cert"

    cert_path         = "${var.cert_path}"
    cert_passphrase   = "${var.cert_passphrase}"
    cluster_prefix    = "${var.cluster_prefix}"
    gce_project       = "${var.gce_project}"
    gce_account_file  = "${var.gce_account_file}"
}

module "etcd" {
    source                = "modules/etcd"

    # provided by modules
    lb_ip                 ="${module.network.etcd_ip}"
    service_network_name  = "${module.network.service_network_name}"
    cert_passphrase       = "${var.cert_passphrase}"
    domain                = "${var.domain}"
    domain_zone_name      = "${var.domain_zone_name}"

    # etcd vars
    etcd_image            = "${var.image}"
    etcd_count            = "${var.etcd_count}"
    etcd_machine_type     = "${var.etcd_machine_type}"

    etcd_data_disk_size   = "${var.etcd_data_disk_size}"
    etcd_image_disk_size  = "${var.etcd_image_disk_size}"

    #gce vars
    gce_project           = "${var.gce_project}"
    gce_region            = "${var.gce_region}"
    gce_zone              = "${var.gce_zone}"
    cluster_prefix        = "${var.cluster_prefix}"
    gce_account_file      = "${var.gce_account_file}"
    gce_network_range     = "${var.gce_service_network_range}"
    gce_pod_network_range = "${var.gce_pod_network_range}"

    # flannel
    flannel_network       = "${var.flannel_network}"
}


module "kubernetes-master" {
    source                = "modules/kubernetes-master"

    etcd_address          = "${module.etcd.pub_address}"
    lb_ip                 ="${module.network.km_ip}"
    service_network_name  = "${module.network.service_network_name}"
    cert_passphrase       = "${var.cert_passphrase}"
    domain                = "${var.domain}"
    domain_zone_name      = "${var.domain_zone_name}"
    api_user              = "${var.api_user}"
    api_pass              = "${var.api_pass}"

    kube_image            = "${var.image}"
    km_disk_size          = "${var.km_disk_size}"
    km_count              = "${var.km_count}"
    km_machine_type       = "${var.km_machine_type}"

    #gce vars
    gce_project           = "${var.gce_project}"
    gce_region            = "${var.gce_region}"
    gce_zone              = "${var.gce_zone}"
    cluster_prefix        = "${var.cluster_prefix}"
    gce_account_file      = "${var.gce_account_file}"
    gce_network_range     = "${var.gce_service_network_range}"

    # flannel
    flannel_network       = "${var.flannel_network}"

}

module "kubernetes-node" {
    source                = "modules/kubernetes-node"

    domain                = "${var.domain}"
    domain_zone_name      = "${var.domain_zone_name}"

    etcd_address          = "${module.etcd.pub_address}"
    lb_ip                 = "${module.network.km_ip}"
    service_network_name  = "${module.network.service_network_name}"
    cert_passphrase       = "${var.cert_passphrase}"

    kube_image            = "${var.image}"
    kn_disk_size          = "${var.kn_disk_size}"
    kn_count              = "${var.kn_count}"
    kn_machine_type       = "${var.kn_machine_type}"

    kn_scale_min_count    = "${var.kn_scale_min_count}"
    kn_scale_max_count    = "${var.kn_scale_max_count}"
    kn_scale_cpu_target   = "${var.kn_scale_cpu_target}"
    kn_scale_cooldown     = "${var.kn_scale_cooldown}"

    #gce vars
    gce_project           = "${var.gce_project}"
    gce_region            = "${var.gce_region}"
    gce_zone              = "${var.gce_zone}"
    cluster_prefix        = "${var.cluster_prefix}"
    gce_account_file      = "${var.gce_account_file}"
    gce_network_range     = "${var.gce_service_network_range}"

    # flannel
    flannel_network       = "${var.flannel_network}"

}
