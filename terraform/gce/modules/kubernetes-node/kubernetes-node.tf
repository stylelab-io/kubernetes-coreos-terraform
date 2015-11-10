/*resource "google_compute_http_health_check" "kubernetes-node" {
    name = "kubernetes-node"
    request_path = "/v2/stats/self"
    check_interval_sec = 5
    timeout_sec = 1
    port = 2379
}

resource "google_compute_target_pool" "kubernetes-node" {
    name = "kubernetes-node"
    health_checks = [ "${google_compute_http_health_check.kubernetes-node.name}" ]
}*/

resource "google_compute_instance_template" "kubernetes-node" {
    name = "kubernetes-node-template"
    instance_description = "kubernetes-node"
    machine_type = "n1-standard-1"
    can_ip_forward = false
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
    tags = ["kubernetes-node"]

    # Create a new boot disk from an image
    disk {
        source_image = "${var.kube_image}"
        auto_delete = true
        boot = true
    }

    network_interface {
        network = "default"
        access_config {

        }
    }

    metadata {
        user-data = "${file("../../coreos/node.yml")}"
    }

    service_account {
        scopes = ["userinfo-email", "compute-ro", "storage-ro"]
    }
}

resource "google_compute_instance_group_manager" "kubernetes-node" {
    description = "Terraform test instance group manager"
    name = "kubernetes-node"
    instance_template = "${google_compute_instance_template.kubernetes-node.self_link}"
    target_pools = ["${google_compute_target_pool.kubernetes-node.self_link}"]
    base_instance_name = "kubernetes-node"
    zone = "europe-west1-b"
    target_size = 1
}
