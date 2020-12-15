data "cloudinit_config" "user_data" {
  part {
    content = templatefile("user-data.sh.tpl", {
      # Master IP and worker nodes for /etc/hosts
      # FIXME Leaky abstraction
      master  = openstack_compute_instance_v2.spark_master.access_ip_v4,
      workers = { for i in range(var.workers):
        # NOTE It doesn't matter if we associate the wrong IP
        # to the wrong host, as long as it's consistent
        format("${local.name_prefix}-worker-%02d", i + 1) => module.networking.worker_ips[i]
      },

      netdata_api_key = var.netdata_api_key,
      nfs_volume      = var.nfs_volume
    })
  }
}

resource "openstack_compute_instance_v2" "spark_worker" {
  count = var.workers

  name        = format("${local.name_prefix}-worker-%02d", count.index + 1)
  image_name  = "Ubuntu 18.04.4 LTS 2020-07-07"
  flavor_name = "de.NBI medium"
  key_pair    = openstack_compute_keypair_v2.spark_keypair.id
  user_data   = data.cloudinit_config.user_data.rendered

  network {
    port = module.networking.worker_ports[count.index]
  }
}
