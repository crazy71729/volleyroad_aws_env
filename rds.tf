data "aws_region" "current" {}

data "aws_db_subnet_group" "existing_rds_subnets" {
  name = "rds-ec2-db-subnet-group-1"
}

data "aws_security_group" "existing_rds_sg" {
  id = "sg-0d108c995b74f4983"  # RDS security group ID
}

data "aws_security_group" "existing_beanstalk_sg" {
  id = "sg-034ae9f71bea7df9f"  # EC2 security group ID
}

resource "aws_db_instance" "volleyball_rds" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  name                   = "volleyball_rental_db"
  username               = "root"
  password               = "volleyroad2024"
  parameter_group_name   = "default.mysql8.0"
  publicly_accessible    = false
  skip_final_snapshot    = true
  vpc_security_group_ids = [data.aws_security_group.existing_rds_sg.id]  # Reference existing RDS security group
  db_subnet_group_name   = data.aws_db_subnet_group.existing_rds_subnets.name  # Reference existing DB subnet group
}

# Remove this resource as it is trying to create an existing security group.
# If you only need to use the existing security groups, there's no need to declare new ones.

# If needed for some other purpose, you can just reference the existing security groups
# rather than creating them, like in the rds_sg resource below.


