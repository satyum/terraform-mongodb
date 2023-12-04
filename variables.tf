variable "region" {
  description = "AWS region"
  type        = string
}

variable "ami_id" {
  description = "Amazon Machine Image (AMI) ID"
  type        = string
  default="ami-053b0d53c279acc90"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the key pair to use for the EC2 instances"
  type        = string
}

variable "subnet_ids" {
  description = "ID of the subnet for the primary instances"
  type        = list(string)
}
variable "vpc_id" {
  description = "ID of the subnet for the primary instances"
  type        = string
}
variable "vpc_cidr_block" {
  description = "ID of the subnet for the primary instances"
  type        = string
}


variable "secondary_count" {
  description = "Number of secondary instances to launch"
  type        = number
}

variable "replica_set" {
  description = "Name of the MongoDB replica set"
  type        = string
}
variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = true
}

variable "delete_on_termination" {
  description = "Whether EBS volume will be deleted when instance gets deleted."
  type        = bool
  default     = true
}

#variable "kms_key_id" {
 #   type    = string
  #  description = "KMS key ID for creating AWS resources"
#}

variable "encrypted" {
  description = "Whether EBS volume will be encrypted."
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Root volume size of the EC2 instance"
  type        = number
  default     = 50
}

variable "volume_type" {
  description = "Volume type for EC2 instance default latest type"
  type        = string
  default     = "gp3"
}


variable "primary_bind_ip" {
  description = "IP address to bind the MongoDB primary instance"
  type        = string
  default = "0.0.0.0"
}

variable "secondary_bind_ip" {
  description = "IP address to bind the MongoDB secondary instances"
  default = "0.0.0.0"
}

variable "mongo_username" {
  description = "Username for MongoDB authentication"
  type        = string
}

variable "mongo_password" {
  description = "Password for MongoDB authentication"
  type        = string
}

variable "mongo_database" {
  description = "MongoDB database name"
  type        = string
}

variable "environment_name" {
  description = "Path to the MongoDB keyfile"
  type        = string
}


variable "keyfile_content" {
  description = "Content of the MongoDB keyfile"
  type        = string
  default     = "SGVsbG8gd29ybGQhCg=="  # Update this with the actual keyfile content
}
