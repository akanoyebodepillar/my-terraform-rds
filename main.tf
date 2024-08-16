provider "aws" {
  region = "us-west-2"
}

# Define the VPC (if not already existing)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Define Subnets (modify as necessary)
resource "aws_subnet" "main" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = element(["us-west-2a", "us-west-2b"], count.index)

  tags = {
    Name = "main-subnet-${count.index}"
  }
}

# Define the security group
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow traffic to RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["68.134.141.81/0"]  # Replace with your specific IP range for better security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# Define the RDS instance
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "13.3"
  instance_class       = "db.t2.micro"
  name                 = "mydatabase"
  username             = "akanoyebodepillar"
  password             = "Zanku419@"   # Ensure you store this securely
  parameter_group_name = "default.postgres13"
  publicly_accessible  = true
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name = "my-rds-instance"
  }
}

# Define the subnet group for RDS
resource "aws_db_subnet_group" "main" {
  name       = "main-subnet-group"
  subnet_ids = aws_subnet.main[*].id

  tags = {
    Name = "main-subnet-group"
  }
}
