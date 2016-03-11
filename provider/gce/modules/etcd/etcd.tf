output "pub_address" {
    value = "${format("https://%s:%s", google_compute_forwarding_rule.etcd.ip_address, "2379")}"
}

# one-liner to generate a new discovery token url
# res=$(curl -w "\n" 'https://discovery.etcd.io/new?size=3');sed -i'' -e "s,discovery: \".*,discovery: \"$res\",g" coreos/etcd.yml;rm coreos/etcd.yml-e;
resource "execute_command" "set_discovery_url" {
  #command = "res=$(curl --silent -w '\n' 'https://discovery.etcd.io/new?size=3');sed -i'' -e 's,discovery: \\".*,discovery: \\"$res\\",g' $PWD/../../coreos/etcd.yml;rm $PWD/../../coreos/etcd.yml-e;"
  command = "res=$(curl --silent -w '\n' 'https://discovery.etcd.io/new?size=${var.etcd_count}');sed -i'' -e \"s,discovery: \\\".*,discovery: \\\"$res\\\",g\" $PWD/../../coreos/etcd.yml;rm $PWD/../../coreos/etcd.yml-e || true;"
  destroy_command = ""
}

resource "google_compute_address" "etcd" {
    name = "${var.cluster_prefix}etcd-address"
}

resource "google_compute_http_health_check" "etcd" {
    name                = "${var.cluster_prefix}etcd-check"
    request_path        = "/health"
    check_interval_sec  = 5
    timeout_sec         = 3
    port                = 2350
}

resource "google_compute_firewall" "allow-etcd-external" {
    name    = "${var.cluster_prefix}allow-etcd-external"
    network = "${var.service_network_name}"

    allow {
        protocol = "tcp"
        ports    = ["2379"]
    }
    source_ranges = ["0.0.0.0/0"]
    target_tags   = ["etcd"]
}

resource "google_compute_firewall" "allow-etcd-internal" {
    name    = "${var.cluster_prefix}allow-etcd-internal"
    network = "${var.service_network_name}"

    allow {
        protocol  = "tcp"
        ports     = ["2379", "2380"]
    }
    source_ranges = ["${var.gce_network_range}","${var.flannel_network}"]
    target_tags   = ["etcd"]
}

resource "google_compute_target_pool" "etcd" {
    name          = "${var.cluster_prefix}etcd-pool"
    health_checks = [ "${google_compute_http_health_check.etcd.name}" ]
    depends_on = [
        "google_compute_http_health_check.etcd",
    ]
}

resource "google_compute_forwarding_rule" "etcd" {
    name        = "${var.cluster_prefix}etcd-forwarding"
    target      = "${google_compute_target_pool.etcd.self_link}"
    port_range  = "2379-2380"

    depends_on = [
        "google_compute_target_pool.etcd",
    ]
}

resource "google_dns_record_set" "etcd" {
    managed_zone  = "${var.domain_zone_name}"
    name          = "etcd-lb.${var.domain}."
    type          = "A"
    ttl           = 60
    rrdatas       = ["${google_compute_forwarding_rule.etcd.ip_address}"]
}

resource "template_file" "cloud_config" {
    template = "../../coreos/etcd.yml"

    vars {
        cluster_prefix  = "${var.cluster_prefix}"
        lb_ip           = "${var.lb_ip}"
        cert_passphrase = "${var.cert_passphrase}"
        domain          = "${var.domain}"
        pod_network     = "${var.gce_pod_network_range}"
    }

    depends_on = [
        "execute_command.set_discovery_url"
    ]
}

resource "google_compute_instance_template" "etcd" {
    name                  = "${var.cluster_prefix}etcd-template"
    description           = "A template for etcd2 instances"
    instance_description  = "A etcd2 node"
    machine_type          = "${var.etcd_machine_type}"
    can_ip_forward        = false
    tags                  = ["etcd"]

    disk {
        source_image  = "${var.etcd_image}"
        auto_delete   = true
        boot          = true
    }

    network_interface {
        network = "${var.service_network_name}"
        access_config {
            // Ephemeral IP
        }
    }

    metadata {
        user-data = "${template_file.cloud_config.rendered}"
    }

    service_account {
        scopes = ["userinfo-email", "compute-ro", "storage-ro"]
    }

    scheduling {
      automatic_restart   = true
      on_host_maintenance = "MIGRATE"
    }

    depends_on = [
        "execute_command.set_discovery_url",
        "template_file.cloud_config",
    ]
}

resource "google_compute_instance_group_manager" "etcd" {
    name                = "${var.cluster_prefix}etcd-group-manager"
    description         = "Terraform test instance group manager"
    instance_template   = "${google_compute_instance_template.etcd.self_link}"
    target_pools        = ["${google_compute_target_pool.etcd.self_link}"]
    base_instance_name  = "${var.cluster_prefix}etcd"
    zone                = "${var.gce_zone}"
    target_size         = "${var.etcd_count}"

    depends_on = [
        "google_compute_instance_template.etcd",
        "google_compute_target_pool.etcd",
    ]
}
