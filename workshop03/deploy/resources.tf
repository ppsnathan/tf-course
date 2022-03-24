data "digitalocean_ssh_key" "my-key" {
  name = "my-key"
}

data digitalocean_image mydroplet_image {
  name = "code-server"
}

//Step 2 - Generate nginx.conf
resource local_file inventory_yaml {
  filename = "inventory.yaml"
  content = templatefile("inventory.yaml.tftpl", {
    nginx_ip = digitalocean_droplet.nginx.ipv4_address
    private_key = var.private_key
    code_server_password = var.code_server_password
    code_server_name = "code-${digitalocean_droplet.nginx.ipv4_address}.nip.io"
  })
  file_permission = "0644"
  }

//create a file with username@ip for ease of ssh later
resource local_file root_at_ip {
    filename = "root@${digitalocean_droplet.nginx.ipv4_address}"
    content = ""
    file_permission = "0644"
}

//Step 3 Provision droplet
resource "digitalocean_droplet" "nginx" {
    name = "nginx"
    image = data.digitalocean_image.mydroplet_image.image
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

output nginx_ip {
    value = digitalocean_droplet.nginx.ipv4_address
}