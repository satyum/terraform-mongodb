
module "mongodb" {
  source = "./mongodb"

  region            = "us-east-1"
  instance_type     = "t2.micro"
  key_name          = "mongodb"
  vpc_id = ""
  subnet_id         = "subnet-0e1a6877842dfe1bf"
  private_subnet_id = "subnet-02d9b27100c33fbdb"
  secondary_count   = 2
  replica_set       = "my-replica-set"
  mongo_username    = "admin"
  mongo_database    = "mydb"
  mongo_password=""
  environment_name="test"
}


  
