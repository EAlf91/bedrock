module "vpc" {
  source = "../modules/vpc"
}

module "rds" {
  source             = "../modules/rds"
  private_subnet_ids = module.vpc.private_subnets_ids
  public_subnet_id   = module.vpc.public_subnet_id
  vpc_id             = module.vpc.vpc_id
}

module "bedrock" {
  source                  = "../modules/bedrock"
  rds_cluster_arn         = module.rds.cluster_arn
  rds_password_secret_arn = module.rds.master_user_secret_arn
  table_name              = "bedrock_integration_512.bedrock_kb_512"
  dimensions              = 512
}
