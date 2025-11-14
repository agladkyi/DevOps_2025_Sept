terraform {
  backend "s3" {
    bucket         = "pasv-course-gladkyi-tf-state-lesson14-stg"
    key            = "staging/pasv_project.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}
