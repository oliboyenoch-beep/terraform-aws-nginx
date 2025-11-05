terraform {
  backend "s3" {
    bucket         = "my-terraform-state-johnenoch"   # your S3 bucket name
    key            = "terraform/state.tfstate"        # path within the bucket
    region         = "us-east-1"                      # your region
    dynamodb_table = "terraform-locks"                # your DynamoDB table name
    encrypt        = true                             # encrypt state file at rest
  }
}
