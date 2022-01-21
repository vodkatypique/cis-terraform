variable "gcp_machine_type" {
  description = "GCP default instance type"
  default = "e2-micro" # Low cost long term 
}
variable "gcp_startup_file" {
  description = "GCP default startup script"
  default = "./init/gcp/debian.sh"
}
variable "gcp_balancer_iam" {
  description = "Service account with instances list permissions"
  default = "balancer@cis4-332208.iam.gserviceaccount.com"
}

variable "app_id" {
  description = "App instance name"
}

variable "ansible_url" {
  description = "Ansible git source repository"
}
variable "ansible_ref" {
  description = "Ansible git source tag"
}