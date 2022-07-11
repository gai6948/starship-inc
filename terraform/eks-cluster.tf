data "aws_caller_identity" "current" {}

data "aws_ami" "ubuntu" {
  for_each    = toset(["amd64", "arm64"])
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu-eks/k8s_${var.kubernetes_version}/images/hvm-ssd/ubuntu-focal-20.04-${each.key}-server-*"]
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name = "starship-inc-dev-eks-${random_string.suffix.result}"
  account_id   = data.aws_caller_identity.current.account_id
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 17.23.0"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  cluster_enabled_log_types     = ["api", "audit", "authenticator"]
  cluster_log_retention_in_days = 14
  write_kubeconfig              = false
  manage_aws_auth               = true
  enable_irsa                   = true

  map_users = [
    {
      username = "admin",
      userarn  = "arn:aws:iam::${local.account_id}:user/admin",
      groups   = ["system:masters"]
    },
    {
      username = "starship-inc-builder",
      userarn  = "arn:aws:iam::${local.account_id}:user/starship-inc-builder",
      groups   = ["system:masters"]
    }
  ]

  node_groups_defaults = {
    additional_tags = {
      "k8s.io/cluster-autoscaler/enabled"               = "true"
      "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
    }
  }

  node_groups = {
    m_amd_large = {
      name             = "m_amd64_large_od_1"
      min_capacity     = 3
      max_capacity     = 9
      desired_capacity = 3

      instance_types = ["m6i.large", "m5.large", "m5a.large"]
      capacity_type  = "ON_DEMAND"

      ami_id                 = data.aws_ami.ubuntu["amd64"].image_id
      ami_is_eks_optimized   = true
      create_launch_template = true

      disk_type = "gp3"
      disk_size = 50

      update_config = {
        max_unavailable = 1
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
