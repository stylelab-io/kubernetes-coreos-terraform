/*output "network_name" {
    value = "${google_compute_network.default.name}"
}*/

output "km_api_ips" {
    value = "${formatlist("%s",google_compute_address.kmapi.*.address)}"
}

output "etcd_ips" {
    value = "${formatlist("%s",google_compute_address.etcd.*.address)}"
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

/*resource "google_compute_network" "default" {
    name = "${var.gce_network_name}"
    ipv4_range = "${var.gce_network_range}"
}*/

# allow icmp and rdp
resource "google_compute_firewall" "allow-rdp-icmp" {
    name = "allow-rdp-icmp"
    network = "${var.gce_network_name}"
    source_ranges = ["0.0.0.0/0"]
    allow {
        protocol = "icmp"
    }
    allow {
        protocol = "tcp"
        ports = ["3389"]
    }
#    depends_on = [
#        "google_compute_network.default",
#    ]
}

# allow ssh
resource "google_compute_firewall" "allow-ssh" {
    name = "allow-ssh"
    network = "${var.gce_network_name}"
    source_ranges = ["0.0.0.0/0"]
    allow {
        protocol = "tcp"
        ports = ["22"]
    }
#    depends_on = [
#        "google_compute_network.default",
#    ]
}
# allow all from internal network
resource "google_compute_firewall" "allow-all-internal" {
    name = "allow-all-internal"
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
#    depends_on = [
#        "google_compute_network.default",
#    ]
}
# http(s) 80,443,8080
resource "google_compute_firewall" "allow-web" {
    name = "allow-web"
    network = "${var.gce_network_name}"
    source_ranges = ["0.0.0.0/16"]
    target_tags = ["web"]
    allow {
        protocol = "tcp"
        ports = ["80", "443", "8080"]
    }
    #depends_on = [
  #      "google_compute_network.default",
#    ]
}
