resource "execute_command" "ca_gen" {
  command = "../../tools/etcd-ca --depot-path ${var.etcd_cert_path} init --passphrase ${var.etcd_cert_passphrase}"
  destroy_command = "rm -rf ${var.etcd_cert_path}"
}
