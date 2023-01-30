
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terrform-s3-bucket-2"
 
}



resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
      status = "Enabled"
    }
  
}


resource "aws_dynamodb_table" "terraform_lock" {
    name = "terraform-dynamodb-lock"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
      name = "LockID"
      type = "S" 
    }
  
}


terraform {
  backend "s3" {
    bucket = "my-terrform-s3-bucket-2"
    key = "dev/terraform.tfstate"
    region = "us-east-1"

    
   }
 }