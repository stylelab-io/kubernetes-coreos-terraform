output "pub_address" {
    value = "${format("http://%s:%s", google_compute_forwarding_rule.etcd.ip_address, "2379")}"
}

resource "google_compute_address" "etcd" {
    name = "etcd-address"
}

resource "google_compute_http_health_check" "etcd" {
    name = "etcd"
    request_path = "/v2/stats/self"
    check_interval_sec = 5
    timeout_sec = 1
    port = 2379
}

resource "google_compute_firewall" "etcd-ext" {
    name = "etcd-ext"
    network = "${var.network_name}"

    allow {
        protocol = "tcp"
        ports = ["2379", "2380"]
    }
    source_ranges = ["0.0.0.0/0"]
    target_tags = ["etcd"]
}

resource "google_compute_firewall" "etcd-int" {
    name = "etcd-int"
    network = "${var.network_name}"

    allow {
        protocol = "tcp"
        ports = ["2379", "2380"]
    }
    source_ranges = ["0.0.0.0/0"]
    target_tags = ["etcd"]
}

resource "google_compute_target_pool" "etcd" {
    name = "etcd"
    health_checks = [ "${google_compute_http_health_check.etcd.name}" ]
}

resource "google_compute_forwarding_rule" "etcd" {
    name = "etcd"
    target = "${google_compute_target_pool.etcd.self_link}"
    port_range = "2379-2380"

    depends_on = [
        "google_compute_target_pool.etcd",
    ]
}

resource "google_compute_instance_template" "etcd" {
    name = "etcd-node-template"
    description = "template description"
    instance_description = "description assigned to instances"
    machine_type = "n1-standard-1"
    can_ip_forward = false
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
    tags = ["etcd"]

    disk {
        source_image = "coreos-alpha-815-0-0-v20150924"
        auto_delete = true
        boot = true
    }

    network_interface {
        network = "default"
        access_config {
            // Ephemeral IP
        }
    }

    metadata {
        user-data = "${file("../../coreos/etcd.yml")}"
    }

    service_account {
        scopes = ["userinfo-email", "compute-ro", "storage-ro"]
    }
}

resource "google_compute_instance_group_manager" "etcd" {
    description = "Terraform test instance group manager"
    name = "etcd"
    instance_template = "${google_compute_instance_template.etcd.self_link}"
    target_pools = ["${google_compute_target_pool.etcd.self_link}"]
    base_instance_name = "etcd"
    zone = "europe-west1-b"
    target_size = 2

    depends_on = [
        "google_compute_instance_template.etcd",
        "google_compute_target_pool.etcd",
    ]
}
