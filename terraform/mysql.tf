module "mysql_cluster" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "7.2.2"

  name           = "dev-aurora-db-mysql"
  engine         = "aurora-mysql"
  engine_version = "5.7"
  instances = {
    one = {
      instance_class = "db.r6g.2xlarge"
    }
  }

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  create_security_group  = true
  allowed_cidr_blocks    = module.vpc.private_subnets_cidr_blocks

  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10

  db_parameter_group_name         = "default"
  db_cluster_parameter_group_name = "default"

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
