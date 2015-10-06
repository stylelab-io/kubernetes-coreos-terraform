resource "google_compute_http_health_check" "kubernetes-master" {
    name = "kubernetes-master"
    request_path = "/v2/stats/self"
    check_interval_sec = 5
    timeout_sec = 1
    port = 2379
}

resource "google_compute_firewall" "etcd-ext" {
    name = "etcd-ext"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["2379", "2380"]
    }
    source_ranges = ["0.0.0.0/0"]
    target_tags = ["etcd"]
}

resource "google_compute_firewall" "etcd-int" {
    name = "etcd-int"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["2379", "2380"]
    }
    source_ranges = ["0.0.0.0/0"]
    target_tags = ["etcd"]
}


resource "template_file" "cloud_config" {
    filename = "../../coreos/master.yml"
    vars {
      #  etcd_address = "${var.etcd_address}"
    }
}

resource "google_compute_target_pool" "kubernetes-master" {
    name = "kubernetes-master"
    health_checks = [ "${google_compute_http_health_check.kubernetes-master.name}" ]
}

resource "google_compute_instance_template" "kubernetes-master" {
    name = "kubernetes-master-template"
    description = "template description"
    instance_description = "description assigned to instances"
    machine_type = "n1-standard-1"
    can_ip_forward = false
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
    tags = ["kubernetes-master", "web", "etcd"]

    # Create a new boot disk from an image
    disk {
        source_image = "coreos-alpha-815-0-0-v20150924"
        auto_delete = true
        boot = true
    }

    network_interface {
        network = "default"
        access_config {

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
