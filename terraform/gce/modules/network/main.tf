output "network_name" {
    value = "${google_compute_network.default.name}"
}

output "km_ip" {
    value = "${google_compute_address.kmapi.0.address}"
}

output "etcd_ip" {
    value = "${google_compute_address.etcd.0.address}"
}

provider "google" {
    account_file = "${file("${var.gce_account_file}")}"
    project = "${var.gce_project}"
    region = "${var.gce_region}"
}

resource "google_compute_address" "kmapi" {
    name = "${var.gce_cluster_name}-kmapi-ip"
}

resource "google_compute_address" "etcd" {
    name = "${var.gce_cluster_name}-etcd-ip"
}

resource "google_compute_network" "default" {
    name = "${var.gce_network_name}"
    ipv4_range = "${var.gce_network_range}"
}

# allow icmp and rdp
resource "google_compute_firewall" "allow-rdp-icmp-ext" {
    name = "-${var.gce_network_name}-allow-rdp-icmp-ext"
    network = "${var.gce_network_name}"
    source_ranges = ["0.0.0.0/0"]
    allow {
        protocol = "icmp"
    }
    allow {
        protocol = "tcp"
        ports = ["3389"]
    }
    depends_on = [
        "google_compute_network.default",
    ]
}

# allow ssh
resource "google_compute_firewall" "allow-ssh-ext" {
    name = "${var.gce_network_name}-allow-ssh-ext"
    network = "${var.gce_network_name}"
    source_ranges = ["0.0.0.0/0"]
    allow {
        protocol = "tcp"
        ports = ["22"]
    }
    depends_on = [
        "google_compute_network.default",
    ]
}

# allow all from internal network
resource "google_compute_firewall" "allow-all-internal" {
    name = "${var.gce_network_name}-allow-all-internal"
    network = "${var.gce_network_name}"
    source_ranges = ["${var.gce_network_range}"]
    allow {
        protocol = "udp"
        ports = ["1-65535"]
    }
    allow {
        protocol = "tcp"
        ports = ["1-65535"]
    }
    depends_on = [
        "google_compute_network.default",
    ]
}
# http(s) 80,443,8080
resource "google_compute_firewall" "allow-web-external" {
    name = "${var.gce_network_name}-allow-web-external"
    network = "${var.gce_network_name}"
    source_ranges = ["0.0.0.0/0"]
    target_tags = ["web"]
    allow {
        protocol = "tcp"
        ports = ["80", "443", "8080"]
    }
    depends_on = [
        "google_compute_network.default",
    ]
}
