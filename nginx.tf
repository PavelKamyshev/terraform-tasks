provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Create a container nginx
resource "docker_container" "mynginx" {
  name  = "nginx"
  image = "${docker_image.nginx.latest}"
  hostname = "nginx"
  depends_on = ["docker_container.tomcat"]
  links = ["mytomcat"]

  upload {
  content = "${var.tomcat_conf}"
#    content = "server {\n  listen          80;\n  server_name     localhost;\n location / { \n        proxy_set_header X-Forwarded-Host $host;\n        proxy_set_header X-Forwarded-Server $host;\n        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n        proxy_pass http://tomcat:8080/;\n  }\n}\n"
    file = "/etc/nginx/conf.d/default.conf"
  }
  ports {
    internal = "80"
    external = "80"
  }
  must_run = "true"
  restart = "on-failure"

}

# Create a container tomcat
resource "docker_container" "tomcat" {
  name  = "mytomcat"
  image = "${docker_image.tomcat.latest}"
  hostname = "tomcat"
  must_run = "true"
  restart = "on-failure"
}

# Create a image nginx
resource "docker_image" "nginx" {
  name = "nginx:latest"
#  keep_locally = "true"
}

# Create a image tomcat
resource "docker_image" "tomcat" {
  name = "tomcat:latest"
  keep_locally = "true"
}
module "child" {
  source = "./child"

  memory = "1G"
}

output "child_memory" {
  value = "${module.child.received}"
}


output "tomcat_ip" {
  value = "${docker_container.tomcat.ip_address}"
}

output "nginx_ip" {
  value = "${docker_container.mynginx.ip_address}"
}
output "tomcat_hostname" {
  value = "${docker_container.tomcat.hostname}"
}

output "nginx_hostname" {
  value = "${docker_container.mynginx.hostname}"
}

terraform {
  backend "consul" {
    address = "demo.consul.io"
    path    = "getting-started-dwqqdwqdqsd"
    lock    = false
  }
}
