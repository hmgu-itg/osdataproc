resource "openstack_compute_instance_v2" "spark_master" {
  name        = "${local.name_prefix}-master"
  image_name  = "Ubuntu 18.04.4 LTS 2020-07-07"
  flavor_name = "de.NBI medium"
  key_pair    = openstack_compute_keypair_v2.spark_keypair.id

  network {
    port = module.networking.master_port
  }
}

resource "openstack_compute_volume_attach_v2" "spark_volume" {
  count       = var.nfs_volume == "" ? 0 : 1
  instance_id = openstack_compute_instance_v2.spark_master.id
  volume_id   = var.nfs_volume
}

#resource "openstack_compute_floatingip_associate_v2" "public_ip" {
#  floating_ip = module.networking.floating_ip
#  instance_id = openstack_compute_instance_v2.spark_master.id
#}
