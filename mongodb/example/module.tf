
module "mongodb" {
  source = "./mongodb"

  region            = "us-east-1"
  instance_type     = "t2.micro"
  key_name          = "satyam-terraform-nvirginia"
  vpc_id            = "vpc-0803d89825ac7428d"
  subnet_id         = "subnet-027eb9ffb346d7806"
  private_subnet_id = "subnet-027eb9ffb346d7806"
  secondary_count   = 2
  replica_set       = "my-replica-set"
  mongo_username    = "admin"
  mongo_database    = "mydb"
  mongo_password=""
  environment_name="test"
}


  
