resource "execute_command" "ca_gen" {
  command = "../../tools/etcd-ca --depot-path='${var.cert_path}' init --passphrase='${var.cert_passphrase}'"
  destroy_command = "rm -rf ${var.cert_path}"
}

resource "execute_command" "ca_to_metadata" {
  command = "gcloud --project ${var.gce_project} compute project-info add-metadata --metadata-from-file ${var.cluster_prefix}ca-crt-etcd=$PWD/${var.cert_path}/ca.crt"
  destroy_command = "gcloud --project ${var.gce_project} compute project-info remove-metadata --keys=${var.cluster_prefix}ca-crt-etcd"

  depends_on = [
      "execute_command.ca_gen"
  ]
}

resource "execute_command" "ca_key_to_metadata" {
  command = "gcloud --project ${var.gce_project} compute project-info add-metadata --metadata-from-file ${var.cluster_prefix}ca-key-etcd=$PWD/${var.cert_path}/ca.key"
  destroy_command = "gcloud --project ${var.gce_project} compute project-info remove-metadata --keys=${var.cluster_prefix}ca-key-etcd"

  depends_on = [
      "execute_command.ca_gen",
      "execute_command.ca_to_metadata"
  ]
}

resource "execute_command" "ca_info_to_metadata" {
  command = "gcloud --project ${var.gce_project} compute project-info add-metadata --metadata-from-file ${var.cluster_prefix}ca-info-etcd=$PWD/${var.cert_path}/ca.crt.info"
  destroy_command = "gcloud --project ${var.gce_project} compute project-info remove-metadata --keys=${var.cluster_prefix}ca-info-etcd"

  depends_on = [
      "execute_command.ca_gen",
      "execute_command.ca_to_metadata",
      "execute_command.ca_key_to_metadata"
  ]
}
