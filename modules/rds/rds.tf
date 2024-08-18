resource "aws_secretsmanager_secret" "aurora_secret" {
  name = "aurora-secret"

  tags = {
    Name = "aurora-secret"
  }
}

resource "aws_kms_key" "postgres" {
  description = "Postgres Secret"
}

resource "aws_rds_cluster" "postgres" {
  cluster_identifier            = "bedrock"
  engine                        = "aurora-postgresql"
  engine_mode                   = "provisioned"
  engine_version                = "16.1"
  database_name                 = "postgres"
  master_username               = "postgres"
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.postgres.key_id
  vpc_security_group_ids        = [aws_security_group.rds_sg.id]
  db_subnet_group_name          = aws_db_subnet_group.aurora.name
  enable_http_endpoint          = true # needed for data api for bedrock

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "postgres" {
  identifier         = "bedrock-writer-one"
  cluster_identifier = aws_rds_cluster.postgres.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.postgres.engine
  engine_version     = aws_rds_cluster.postgres.engine_version
}

resource "aws_db_subnet_group" "aurora" {
  name       = "aurora-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "aurora-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
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

resource "aws_iam_role" "ssm_role" {
  name = "ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_role_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_instance" "bastion" {
  ami                  = "ami-04a81a99f5ec58529" # Change to your desired AMI
  instance_type        = "t2.micro"
  subnet_id            = var.public_subnet_id
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}