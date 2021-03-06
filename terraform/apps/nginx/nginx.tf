variable "user" {}
variable "priv_key" {}
variable "primary_consul" {}
variable "nginx_server_count" {}
variable "subnet_id" {}
variable "hcvt_sg_id" {}

data aws_ami "nginx" {
  most_recent = true
  owners      = ["self"]
  name_regex  = "ubuntu-16-nginx*"
}

resource "aws_instance" "nginx" {
  ami                    = "${data.aws_ami.nginx.id}"
  instance_type          = "t2.micro"
  count                  = "${var.nginx_server_count}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.hcvt_sg_id}"]

  tags = {
    env = "hcvt-demo"
  }

  connection {
    user        = "${var.user}"
    private_key = "${var.priv_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.primary_consul} > /tmp/consul-server-addr",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /ramdisk",
      "sudo mount -t tmpfs -o size=20M,mode=700 tmpfs /ramdisk"
    ]
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install.sh",
      "${path.module}/scripts/secret_page.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl enable consul.service",
      "sudo systemctl start consul",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/scripts/token_mgmt.sh"
    destination = "/tmp/token_mgmt.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/token_mgmt.service"
    destination = "/tmp/token_mgmt.service"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/token_mgmt.timer"
    destination = "/tmp/token_mgmt.timer"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/token_mgmt.sh /usr/local/bin/token_mgmt.sh",
      "sudo chmod +x /usr/local/bin/token_mgmt.sh",
      "sudo mv /tmp/token_mgmt.service /lib/systemd/system/token_mgmt.service",
      "sudo mv /tmp/token_mgmt.timer /lib/systemd/system/token_mgmt.timer",
      "sudo systemctl start token_mgmt.timer",
      "sudo systemctl enable token_mgmt.timer"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/scripts/token_fetcher.sh"
    destination = "/tmp/token_fetcher.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/token_fetcher.sh",
      "echo /tmp/token_fetcher.sh | at now + 1 min",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl enable consul-template.service",
      "sudo systemctl start consul-template"
    ]
  }

}
