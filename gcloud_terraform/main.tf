provider "google" {
  credentials = file("~/My First Project-f2d4cb3f9f22.json")
  project     = "cosmic-slate-292412"
  region      = "europe-west6"
}

resource "google_compute_instance" "appserver" {
  count = 2
  machine_type = "e2-medium"
  name = "macshine-${count.index + 1}"
  zone = "europe-west6-a"
  

  metadata = {
    ssh-keys = "vs150502:${file("~/.ssh/id_rsa.pub")}"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20201008"
    }
  }
  
  network_interface {
    network = "my-network-184"
    access_config {
    }
  }

  provisioner "local-exec" {
     command = "echo The servers IP address is ${self.network_interface.0.access_config.0.nat_ip }"
  }

  provisioner "remote-exec" {
    inline = ["echo ${self.network_interface.0.access_config.0.nat_ip} >> ~/IP_address.txt"]

    connection {
          type = "ssh"
          user = "vs150502"
          private_key = file("~/.ssh/id_rsa")
          host = self.network_interface.0.access_config.0.nat_ip
    }
  }
}



resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_instance.appserver.network_interface.network

  allow {
    protocol = "tcp"
    ports    = ["22", "80-9090"]
  }

}
