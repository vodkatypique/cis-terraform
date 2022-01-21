terraform {
  required_version = ">= 0.14"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.0"
    }
  }

  backend "http" {
    # using Gitlab managed terraform state 
  }
}

provider "google" {
  # using environment variables GOOGLE_APPLICATION_CREDENTIALS and GCLOUD_*
}