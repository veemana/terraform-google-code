provider "google" {
  credentials = file("/Users/veemana/sme-sessions/secrets/google-key/fine-craft-384611-e1246396d492.json")
  project     = "fine-craft-384611"
  region      = "us-central1"
}
