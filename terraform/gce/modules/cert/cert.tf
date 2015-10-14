resource "execute_command" "ca_gen" {
  #command = "res=$(curl -w '\n' 'https://discovery.etcd.io/new?size=3');sed -i'' -e 's,discovery: \\".*,discovery: \\"$res\\",g' $PWD/../../coreos/etcd.yml;rm $PWD/../../coreos/etcd.yml-e;"
  command = "yes '' | ../../tools/etcd-ca --depot-path ${var.etcd_ca_path} init"
  destroy_command = "rm -rf ${var.etcd_ca_path}"
}
