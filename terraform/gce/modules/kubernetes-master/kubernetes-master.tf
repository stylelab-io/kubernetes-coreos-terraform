resource "google_compute_http_health_check" "kubernetes-master" {
    name = "${var.gce_cluster_name}-kube-master"
    request_path = "/v2/stats/self"
    check_interval_sec = 5
    timeout_sec = 1
    port = 2379
}

resource "google_compute_firewall" "kube-internal" {
    name = "${var.gce_cluster_name}-allow-kube-master-internal"
    network = "${var.network_name}"

    allow {
        protocol = "tcp"
        ports = ["8080", "443"]
    }
    source_ranges = ["${var.gce_network_range},${var.flannel_network}"]
    target_tags = ["kube-master"]
}

resource "google_compute_firewall" "kube-external" {
    name = "${var.gce_cluster_name}-allow-kube-master-external"
    network = "${var.network_name}"

    allow {
        protocol = "tcp"
        ports = ["8080", "443"]
    }
    source_ranges = ["${var.gce_network_range},${var.flannel_network}"]
    target_tags = ["kube-master"]
}

resource "template_file" "cloud_config" {
    filename = "../../coreos/master.yml"
    vars {
      #  etcd_address = "${var.etcd_address}"
    }
}

resource "google_compute_target_pool" "kubernetes-master" {
    name = "${var.gce_cluster_name}-kube-master"
    health_checks = [ "${google_compute_http_health_check.kubernetes-master.name}" ]
}

resource "google_compute_instance_template" "kubernetes-master" {
    name = "${var.gce_cluster_name}-kube-master-template"
    description = "Kubernetes Master instance template"
    instance_description = "Kubernetes Master instace"
    machine_type = "n1-standard-1"
    can_ip_forward = true
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
    tags = ["kube-master"]

    # Create a new boot disk from an image
    disk {
        source_image = "coreos-alpha-815-0-0-v20150924"
        auto_delete = true
        boot = true
    }

    network_interface {
        network = "${var.network_name}"
        access_config {
            //Ephemeral
        }
    }

    metadata {
        user-data = "${template_file.cloud_config.rendered}"
    }

    service_account {
        scopes = ["userinfo-email", "compute-ro", "storage-ro"]
    }
    depends_on = [
        "template_file.cloud_config",
    ]
}

resource "google_compute_instance_group_manager" "kubernetes-master" {
    description = "Terraform test instance group manager"
    name = "kubernetes-master"
    instance_template = "${google_compute_instance_template.kubernetes-master.self_link}"
    target_pools = ["${google_compute_target_pool.kubernetes-master.self_link}"]
    base_instance_name = "kubernetes-master"
    zone = "europe-west1-b"
    target_size = 2
    depends_on = [
        "google_compute_instance_template.kubernetes-master",
        "google_compute_target_pool.kubernetes-master",
    ]
}
