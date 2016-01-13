# self_link? see: hashicorp/terraform#3226
output "service_network_name" {
    value = "${google_compute_network.service.name}"
    /*value = "default"*/
}

output "pod_network_name" {
    value = "${google_compute_network.pod.name}"
    /*value = "default"*/
}

output "km_ip" {
    value = "${google_compute_address.kmapi.0.address}"
}

output "etcd_ip" {
    value = "${google_compute_address.etcd.0.address}"
}

resource "google_compute_address" "kmapi" {
    name = "${var.cluster_prefix}kmapi-ip"
}

resource "google_compute_address" "etcd" {
    name = "${var.cluster_prefix}etcd-ip"
}

resource "google_compute_network" "service" {
    name = "${var.gce_service_network_name}"
    ipv4_range = "${var.gce_service_network_range}"
}

resource "google_compute_network" "pod" {
    name = "${var.gce_pod_network_name}"
    ipv4_range = "${var.gce_pod_network_range}"
}

# allow icmp and rdp
resource "google_compute_firewall" "allow-rdp-icmp-ext" {
    name          = "${var.gce_service_network_name}-allow-rdp-icmp-ext"
    network       = "${var.gce_service_network_name}"
    source_ranges = ["0.0.0.0/0"]
    allow {
        protocol  = "icmp"
    }
    allow {
        protocol  = "tcp"
        ports     = ["3389"]
    }
    depends_on = [
        "google_compute_network.service",
    ]
}

# allow ssh
resource "google_compute_firewall" "allow-ssh-ext" {
    name          = "${var.gce_service_network_name}-allow-ssh-ext"
    network       = "${var.gce_service_network_name}"
    source_ranges = ["0.0.0.0/0"]
    allow {
        protocol  = "tcp"
        ports     = ["22"]
    }
    depends_on = [
        "google_compute_network.service",
    ]
}

# allow all from internal network
resource "google_compute_firewall" "allow-all-internal" {
    name          = "${var.gce_service_network_name}-allow-all-internal"
    network       = "${var.gce_service_network_name}"
    source_ranges = ["${var.gce_service_network_range}", "${var.gce_pod_network_range}"]
    allow {
        protocol  = "udp"
        ports     = ["1-65535"]
    }
    allow {
        protocol  = "tcp"
        ports     = ["1-65535"]
    }
    depends_on = [
        "google_compute_network.service",
    ]
}
# http(s) 80,443,8080
resource "google_compute_firewall" "allow-web-external" {
    name          = "${var.gce_service_network_name}-allow-web-external"
    network       = "${var.gce_service_network_name}"
    source_ranges = ["0.0.0.0/0"]
    target_tags   = ["web"]
    allow {
        protocol  = "tcp"
        ports     = ["80", "443", "8080"]
    }
    depends_on = [
        "google_compute_network.service",
    ]
}

resource "google_compute_firewall" "allow-pod-all-internal" {
    name          = "${var.gce_pod_network_name}-allow-pod-all-internal"
    network       = "${var.gce_pod_network_name}"
    source_ranges = ["${var.gce_service_network_range}", "${var.gce_pod_network_range}"]
    allow {
        protocol = "udp"
        ports    = ["1-65535"]
    }
    allow {
        protocol = "tcp"
        ports    = ["1-65535"]
    }
    depends_on = [
        "google_compute_network.pod",
    ]
}
