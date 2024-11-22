terraform {
  backend "s3" {
    bucket         = "strike2" # Same bucket name as created above
    key            = "Custom-Network/terraform/state/terraform.tfstate" # Path in the bucket for the state file
    region         = "ap-northeast-3" # Same region as the bucket
    # dynamodb_table = "terraform-state-locks" # DynamoDB table for state locking
    encrypt        = true
  }
}