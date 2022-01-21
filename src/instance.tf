locals {
  min_workers = 3
  startup_script = templatefile(var.gcp_startup_file, {
    ansible_url = var.ansible_url
    ansible_ref = var.ansible_ref
  })
  # For testing, use "default"
  network = google_compute_network.vpc.name
}

resource "google_compute_region_instance_group_manager" "worker_group" {
  name = "${var.app_id}-cluster"

  base_instance_name = "${var.app_id}-worker"
  version {
    name = "worker"
    instance_template = google_compute_instance_template.worker.id
  }
}
resource "google_compute_region_autoscaler" "worker_scaler" {
  name = "${var.app_id}-cluster-scaler"
  target = google_compute_region_instance_group_manager.worker_group.id

  autoscaling_policy {
    min_replicas = 3
    max_replicas = 9
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}
resource "google_compute_instance_template" "worker" {
  name = "${var.app_id}-worker-tpl"
  machine_type = var.gcp_machine_type

  metadata = {
    app_role = "worker"
  }
  metadata_startup_script = local.startup_script

  tags = ["cluster"]
  disk {
    source_image = "debian-john"
    boot = true
  }

  network_interface {
    network = local.network
  }
}

resource "google_compute_instance" "front" {
  # count = 1
  name = "${var.app_id}-front"
  machine_type = var.gcp_machine_type

  metadata = {
    app_role = "front",
    cluster = google_compute_region_instance_group_manager.worker_group.name
  }
  metadata_startup_script = local.startup_script

  tags = ["web", "http-server", "https-server", "cluster"]

  boot_disk {
    initialize_params {
      image = "debian-john"
    }
  }

  network_interface {
    network = local.network
    access_config { }
  }

  service_account {
    email = var.gcp_balancer_iam
    scopes = ["cloud-platform"] # Using rights from iam role
  }
}

resource "google_compute_instance" "auth" {
  name = "${var.app_id}-auth"
  machine_type = var.gcp_machine_type

  metadata = {
    app_role = "auth"
  }
  metadata_startup_script = local.startup_script

  tags = ["auth"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = local.network
  }
}

output "app_address" {
  value = google_compute_instance.front.network_interface.0.access_config.0.nat_ip
}