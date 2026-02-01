locals {

  # Paste the same IDs you found earlier

  my_vpc_id     = "vpc-0bb7de70641474c0a"        

  my_subnet_ids = ["subnet-078167f270f75f81e", "subnet-0e6cb4132897a3dd1"] 

}



module "eks" {

  source  = "terraform-aws-modules/eks/aws"

  version = "~> 20.0"



  cluster_name    = "project14-cluster-yourname"

  cluster_version = "1.30"



  # --- NETWORK ---

  vpc_id                   = local.my_vpc_id

  subnet_ids               = local.my_subnet_ids

  control_plane_subnet_ids = local.my_subnet_ids



  # --- ACCESS ---

  cluster_endpoint_public_access           = true

  enable_cluster_creator_admin_permissions = true



  # --- RESTRICTIONS FIXES ---

  create_kms_key              = false

  cluster_encryption_config   = {}

  create_cloudwatch_log_group = false

  cluster_enabled_log_types   = []



  # --- NODES ---

  eks_managed_node_groups = {

    default = {

      instance_types = ["t3.medium"]

      min_size       = 1

      max_size       = 2

      desired_size   = 1



      # ---------------------------------------------------------

      # THE CRITICAL FIX: DISABLE LAUNCH TEMPLATES

      # ---------------------------------------------------------

      create_launch_template     = false

      launch_template_name       = ""

      use_custom_launch_template = false

    }

  }

}
