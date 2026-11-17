locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "security_groups" {
  source = "./modules/security-groups"

  name_prefix      = local.name_prefix
  vpc_id           = module.vpc.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

module "ec2" {
  source = "./modules/ec2"

  name_prefix       = local.name_prefix
  instance_type     = var.instance_type
  instance_count    = var.instance_count
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.web_sg_id
  key_name          = var.key_name
  user_data_path    = "${path.module}/scripts/user_data.sh"
}

module "rds" {
  source = "./modules/rds"

  name_prefix       = local.name_prefix
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.db_sg_id
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  instance_class    = var.db_instance_class
}
