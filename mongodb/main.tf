provider "aws" {
  region = var.region
}

 resource "random_string" "autogenerated_password" {
      length  = 16
      special = false
  }

  resource "aws_ssm_parameter" "mongodb_password" {
   
    name        = "/${var.environment_name}/mongodb/PASSWORD"
    description = "mongodb Password"
    type        = "SecureString"
    value       = random_string.autogenerated_password.result
  
  }
resource "aws_ssm_parameter" "mongodb_username" {
  name        = "/${var.environment_name}/mongodb/USERNAME"
  description = "mongodb Username"
  type        = "String"
  value       = var.mongo_username 
  }

  resource "aws_ssm_parameter" "mongodb_database" {
  name        = "/${var.environment_name}/mongodb/DATABASE"
  description = "mongodb database name"
  type        = "String"
  value       = var.mongo_database 
  }



resource "aws_instance" "primary" {
  count         = 1
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.private_subnet_id
  tags = {
    Name = "mongodb-primary"
  }

  provisioner "local-exec" {
    command = "hostnamectl set-hostname mongodb-primary"
  }

  user_data = templatefile("${path.module}/userdata.tpl", {
    is_primary       = true
    replica_set      = var.replica_set
    bind_ip          = "mongodb-primary"
    public_ip        = true
    mongo_username   = var.mongo_username
    mongo_password   = random_string.autogenerated_password.result
    mongo_database   = var.mongo_database
  })

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
}

resource "aws_instance" "secondary" {
  count         = var.secondary_count
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.private_subnet_id  # Use a private subnet ID
  associate_public_ip_address = false    # Ensure no public IP is associated
  tags = {
    Name = "mongodb-secondary-${count.index}"
  }

  provisioner "local-exec" {
    command = "hostnamectl set-hostname mongodb-secondary-${count.index}"
  }

  user_data = templatefile("${path.module}/userdata.tpl", {
    is_primary       = false
    replica_set      = var.replica_set
    bind_ip          = "mongodb-secondary-${count.index}"
    public_ip        = false
    mongo_username   = var.mongo_username
    mongo_password   = var.mongo_password != "" ? var.mongo_password : random_string.autogenerated_password.result

    mongo_database   = var.mongo_database
  })

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
}

resource "aws_security_group" "mongodb" {
  name        = "mongodb"
  description = "Allow MongoDB traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  security_group_id = aws_security_group.mongodb.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm_instance_profile"

  role = aws_iam_role.ssm_role.name

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  provisioner "local-exec" {
    command = "sleep 30"
  }
}
resource "aws_iam_role_policy_attachment" "admin_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
resource "aws_iam_role_policy_attachment" "ssm_role_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}



output "primary_instance_id" {
  value = aws_instance.primary[0].id
}

output "secondary_instance_ids" {
  value = aws_instance.secondary[*].id
}

output "primary_private_ips" {
  value = aws_instance.primary[*].private_ip
}

output "secondary_private_ips" {
  value = aws_instance.secondary[*].private_ip
}

