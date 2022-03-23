data "digitalocean_ssh_key" "digitaleocean" {
  name = "digitaleocean"
}

//image
resource "docker_image" "dov-bear" {
  name = "chukmunnlee/dov-bear:v2"
  keep_locally = true
}

//Container
resource "docker_container" "dov-bear" {
    count = 3
  image = docker_image.dov-bear.latest
    name  = "dov-${count.index}"
    ports {
    internal = "3000"
//    external = "8080"
  }
}

output "digitaleocean"  {
  value = data.digitalocean_ssh_key.digitaleocean.fingerprint
}

output "dov-names"  {
  value = docker_container.dov-bear[*].name
}

output external-ports {
  value = join( ",", [ for p in docker_container.dov-bear[*].ports[*]: element(p, 0).external ])

}
