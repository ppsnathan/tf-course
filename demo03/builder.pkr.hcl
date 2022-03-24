variable DO_token {
    type = string
    sensitive = true
}

variable droplet_size {
    type = string
    default = "s-1vcpu-1gb"
}

variable droplet_image {
    type = string
    default = "ubuntu-20-04-x64"
}

variable droplet_region {
    type = string
    default = "sgp1"
}

source digitalocean mydroplet { 
    api_token = var.DO_token
    region = var.droplet_region
    size = var.droplet_size
    image = var.droplet_image
    snapshot_name = "mydroplet-nginx"
    ssh_username = "root"
}

build { 
    sources = [
        "source.digitalocean.mydroplet"
        ]

    provisioner ansible { 
        playbook_file = "playbook.yaml"
    }
}