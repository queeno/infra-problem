variable "region" {
    description = "The gcloud region to provision infrastructure in"
}

variable "credentials_file_path" {
    description = "The path to the gcloud JSON credentials file"
}

variable "project_name" {
    description = "The gcloud project to use"
}

variable "public_key_path" {
    description = "The path to the public key to distribute to the hosts"
}
