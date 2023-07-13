
module "mongodb" {
  source = "./mongodb"

  region            = "us-east-1"
  instance_type     = "t3.medium"
  key_name          = "satyam-terraform-nvirginia"
  kms_key_id        = "12be95c4-144f-47a9-beaa-67693dc586d7"
  vpc_id            = "vpc-0803d89825ac7428d"
  vpc_cidr_block = "0.0.0.0/0"
  subnet_id         = "subnet-027eb9ffb346d7806"
  private_subnet_id = "subnet-027eb9ffb346d7806"
  secondary_count   = 2
  replica_set       = "my-replica-set"
  mongo_username    = "admin"
  mongo_database    = "mydb"
  mongo_password=""
  environment_name="test"
}


  
