output "kube_master_ip" {
    value = "${google_compute_address.kube-master.ip_address}"
}

resource "google_compute_address" "kube-master" {
    name = "${var.cluster_prefix}kube-master-ip"
}

resource "google_compute_http_health_check" "kube-master" {
    name                = "${var.cluster_prefix}kube-master"
    request_path        = "/health"
    check_interval_sec  = 5
    timeout_sec         = 1
    port                = 8090
}

resource "google_compute_target_pool" "kube-master" {
    name          = "${var.cluster_prefix}kube-master"
    health_checks = [ "${google_compute_http_health_check.kube-master.name}" ]
}

resource "google_compute_forwarding_rule" "kube-master" {
    name    = "${var.cluster_prefix}kube-master-forw"
    target  = "${google_compute_target_pool.kube-master.self_link}"

    depends_on = [
        "google_compute_target_pool.kube-master",
    ]
}

resource "google_dns_record_set" "kube-master" {
    managed_zone  = "${var.domain_zone_name}"
    name          = "kube-master-lb.${var.domain}."
    type          = "A"
    ttl           = 5
    rrdatas       = ["${google_compute_forwarding_rule.kube-master.ip_address}"]
}

resource "google_compute_firewall" "kube-internal" {
    name    = "${var.cluster_prefix}allow-kube-master-internal"
    network = "${var.service_network_name}"

    allow {
        protocol  = "tcp"
        ports     = ["8080", "443"]
    }
    source_ranges = ["${var.gce_network_range}","${var.flannel_network}"]
    target_tags   = ["kube-master"]
}

resource "google_compute_firewall" "kube-external" {
    name    = "${var.cluster_prefix}allow-kube-master-external"
    network = "${var.service_network_name}"

    allow {
        protocol = "tcp"
        ports    = ["443"]
    }
    source_ranges = ["${var.gce_network_range}","${var.flannel_network}"]
    target_tags   = ["kube-master"]
}

resource "template_file" "cloud_config" {
    filename = "../../coreos/master.yml"
    vars {
      cluster_prefix    = "${var.cluster_prefix}"
      lb_ip             = "${var.lb_ip}"
      cert_passphrase   = "${var.cert_passphrase}"
      domain            = "${var.domain}"
      cloud_provider    = "gce"
      etcd_address      = "${var.etcd_address}"
      api_user          = "${var.api_user}"
      api_pass          = "${var.api_pass}"
    }
}

resource "google_compute_instance_template" "kube-master" {
    name                 = "${var.cluster_prefix}kube-master-template"
    description          = "Kube Master instance template"
    instance_description = "Kube Master instace"
    machine_type         = "${var.km_machine_type}"
    can_ip_forward       = true
    automatic_restart    = true
    on_host_maintenance  = "MIGRATE"
    tags                 = ["kube-master", "web"]

    # Create a new boot disk from an image
    disk {
        source_image  = "${var.kube_image}"
        auto_delete   = true
        boot          = true
        disk_size_gb  = "${var.km_disk_size}"
    }

    network_interface {
        network = "${var.service_network_name}"
        access_config {
            //Ephemeral
        }
    }

    metadata {
        user-data = "${template_file.cloud_config.rendered}"
    }

    service_account {
        scopes = ["userinfo-email", "compute-rw", "storage-ro"]
    }
    depends_on = [
        "template_file.cloud_config",
    ]
}

resource "google_compute_instance_group_manager" "kube-master" {
    description         = "Terraform test instance group manager"
    name                = "${var.cluster_prefix}kube-master"
    instance_template   = "${google_compute_instance_template.kube-master.self_link}"
    target_pools        = ["${google_compute_target_pool.kube-master.self_link}"]
    base_instance_name  = "${var.cluster_prefix}kube-master"
    zone                = "${var.gce_zone}"
    target_size         = "${var.km_count}"
    depends_on = [
        "google_compute_instance_template.kube-master",
        "google_compute_target_pool.kube-master",
    ]
}
