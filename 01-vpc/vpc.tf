module "vpc" {
    # source = "../terraform-aws-vpc"
    source = "git::https://github.com/shreenavya71/terraform-aws-vpc.git?ref=main"
    project_name = var.project_name     # mandatory parameters
    common_tags = var.common_tags       # mandatory parameters
    public_subnet_cidrs = var.public_subnet_cidrs     # mandatory parameters
    private_subnet_cidrs = var.private_subnet_cidrs  # mandatory parameters  
    database_subnet_cidrs = var.database_subnet_cidrs  # mandatory parameters
    is_peering_required = var.is_peering_required
}