resource "template_file" "cloud_config" {
    filename = "../../coreos/node.yml"
    vars {
      cluster_prefix    = "${var.cluster_prefix}"
      lb_ip             = "${var.lb_ip}"
      cert_passphrase   = "${var.cert_passphrase}"
      domain            = "${var.domain}"
      cloud_provider    = "gce"
      kube_master_url   = "https://kube-master-lb.${var.domain}"
      etcd_address           = "${var.etcd_address}"
    }
}

resource "google_compute_instance_template" "kube-node" {
    name = "${var.cluster_prefix}kube-node-template"
    instance_description = "kube-node"
    machine_type = "n1-standard-1"
    can_ip_forward = false
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
    tags = ["kube-node"]

    # Create a new boot disk from an image
    disk {
        source_image = "${var.kube_image}"
        auto_delete = true
        boot = true
    }

    network_interface {
        network = "${var.service_network_name}"
        access_config {

        }
    }

    metadata {
        user-data = "${template_file.cloud_config.rendered}"
    }

    service_account {
        scopes = ["userinfo-email", "compute-rw", "storage-ro"]
    }
}

resource "google_compute_target_pool" "kube-node" {
    name = "kube-node-pool"
}

resource "google_compute_autoscaler" "kube-node" {
    name = "${var.cluster_prefix}kube-node-autoscaler"
    zone = "${var.gce_zone}"
    target = "${google_compute_instance_group_manager.kube-node.self_link}"
    autoscaling_policy = {
        max_replicas = 5
        min_replicas = 1
        cooldown_period = 60
        cpu_utilization = {
            target = 0.5
        }
    }
}

resource "google_compute_instance_group_manager" "kube-node" {
    description = "Terraform test instance group manager"
    name = "${var.cluster_prefix}kube-node-manager"
    instance_template = "${google_compute_instance_template.kube-node.self_link}"
    target_pools = ["${google_compute_target_pool.kube-node.self_link}"]
    base_instance_name = "kube-node"
    zone = "europe-west1-b"
#    target_size = 1
}
