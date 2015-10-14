resource "execute_command" "ca_gen" {
  command = "../../tools/etcd-ca --depot-path ${var.etcd_cert_path} init --passphrase ${var.etcd_cert_passphrase}"
  destroy_command = "rm -rf ${var.etcd_cert_path}"
}

resource "execute_command" "ca_to_metadata" {
  command = "gcloud compute project-info add-metadata --metadata-from-file ${var.cluster_prefix}ca-crt-etcd=$PWD/${var.etcd_cert_path}/ca.crt"
  destroy_command = "gcloud compute project-info remove-metadata --keys=${var.cluster_prefix}ca-crt-etcd"

  depends_on = [
      "execute_command.ca_gen"
  ]
}

resource "execute_command" "ca_key_to_metadata" {
  command = "gcloud compute project-info add-metadata --metadata-from-file ${var.cluster_prefix}ca-key-etcd=$PWD/${var.etcd_cert_path}/ca.key"
  destroy_command = "gcloud compute project-info remove-metadata --keys=${var.cluster_prefix}ca-key-etcd"

  depends_on = [
      "execute_command.ca_gen",
      "execute_command.ca_to_metadata"
  ]
}
