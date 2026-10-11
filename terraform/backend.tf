
terraform {
  backend "s3" {
    bucket       = "terraform-state-api-hexagonal-891176261467-363734176-us-east-1"
    key          = "api-hexagonal/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
