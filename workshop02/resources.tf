data "digitalocean_ssh_key" "my-key" {
  name = "my-key"
}

# //image
# resource "docker_image" "dov-bear" {
#   name = "chukmunnlee/dov-bear:v2"
#   keep_locally = true
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
#   env = [
#     "INSTANCE_NAME=dov-${count.index}"
#   ]
# }


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
    
    # //Install nginx pkgs
    # provisioner "remote-exec" {
    #   inline = [
    #     "apt update",
    #     "apt install -y nginx"
    #   ]
      
    # }

    # //Copy conf file over
    # provisioner "file" {
    #     source = "./nginx.conf"
    #     destination = "/etc/nginx/nginx.conf"
    # }   

    # //Restart nginx service to load new conf
    # provisioner "remote-exec" {
    #   inline = [
    #     "systemctl restart nginx"
    #   ]
    # }


    
    }

output "digitalocean"  {
  value = data.digitalocean_ssh_key.my-key.fingerprint
}

# output "dov-names"  {
#   value = docker_container.dov-bear[*].name
# }

# output external-ports {
#   value = join( ",", [ for p in docker_container.dov-bear[*].ports[*]: element(p, 0).external ])

# }

output nginx_ip {
    value = digitalocean_droplet.nginx.ipv4_address
}