resource "local_file" "ansible_inventory" {
  filename        = "${path.root}/terraform.tfstate.d/${var.cluster_name}/hosts_master"
  file_permission = "0644"
  content         = templatefile("ansible-inventory.tpl", {master_ip = module.networking.floating_ip})
}

# TODO Generate TF vars for clean cluster destruction

output "spark_worker_private_ips" {
  value     = module.networking.worker_ips
  sensitive = true
}

output "spark_master_private_ip" {
  value     = openstack_compute_instance_v2.spark_master.access_ip_v4
  sensitive = true
}

output "spark_master_public_ip" {
  value = module.networking.floating_ip
}
