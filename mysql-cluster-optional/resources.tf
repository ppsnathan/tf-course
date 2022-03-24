data "digitalocean_ssh_key" "my-key" {
  name = "my-key"
}


# //Step 2 - Generate nginx.conf
# resource local_file inventory_yaml {
#   filename = "inventory.yaml"
#   content = templatefile("inventory.yaml.tftpl", {
#     node_ip = digitalocean_droplet.nginx.ipv4_address
#     private_key = var.private_key
#     code_server_password = var.code_server_password
#     code_server_name = "code-${digitalocean_droplet.nginx.ipv4_address}.nip.io"
#   })
#   file_permission = "0644"
#   }

# //create a file with username@ip for ease of ssh later
# resource local_file root_at_ip {
#     filename = "root@${digitalocean_droplet.node[*].ipv4_address}"
#     content = ""
#     file_permission = "0644"
# }




# //Container
# resource "docker_container" "dov-bear" {
#     count = 3
#   image = docker_image.dov-bear.latest
#     name  = "dov-${count.index}"
#     ports {
#     internal = "3000"
# //    external = "8080"
#   }
# }
//Step 3 Provision droplet
resource "digitalocean_droplet" "node" {
    count = 3
    name = "node-${count.index}"
    image = var.droplet_image
    region = var.droplet_region
    size = var.droplet_size
    ssh_keys = [ data.digitalocean_ssh_key.my-key.id  ]

    connection {
      type = "ssh"
      user = "root"
      host = self.ipv4_address
      private_key = file(var.private_key)
    }
    
    }

output "digitalocean"  {
  value = data.digitalocean_ssh_key.my-key.fingerprint
}

output "node"  {
  value = digitalocean_droplet.node[*].name
}

output node_ip {
  value = digitalocean_droplet.node[*].ipv4_address
}