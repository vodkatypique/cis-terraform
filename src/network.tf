resource "google_compute_network" "vpc" {
  name = "${var.app_id}-vpc-network"
  routing_mode = "REGIONAL"
  auto_create_subnetworks = true
  #MAYBE: delete_default_routes_on_create = true
}

resource "google_compute_router" "router" {
  name = "${var.app_id}-router"
  network = google_compute_network.vpc.name
}
resource "google_compute_router_nat" "nat" {
  name = "${var.app_id}-nat"
  router = google_compute_router.router.name

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "web" {
  name = "${var.app_id}-web-firewall"
  network = google_compute_network.vpc.name

  allow { # HTTP(S)
    protocol = "tcp"
    ports = ["80", "443"]
  }

  target_tags = ["web"]
}
resource "google_compute_firewall" "auth" {
  name = "${var.app_id}-auth-firewall"
  network = google_compute_network.vpc.name

  allow { # LDAP
    protocol = "tcp"
    ports = ["363"]
  }

  source_tags = ["web"]
  target_tags = ["auth"]
}
resource "google_compute_firewall" "cluster" {
  name = "${var.app_id}-cluster-firewall"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow { # SSH and OpenMPI
    protocol = "tcp"
    ports = ["22", "49990-50009"]
  }

  allow { # NFS
    protocol = "udp"
    ports = ["2049"]
  }

  source_tags = ["cluster"]
  target_tags = ["cluster"]
}