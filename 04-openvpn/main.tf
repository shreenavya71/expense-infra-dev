resource "aws_key_pair" "vpn" {
    key_name   = "openvpn"
    # you can paste the public key directly like this
    #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPb1dpBDXkNS2tdMIxyVL+KAiX2t+S1pDYb/9YR8nfIO navyashreesanthamolla@Navyashrees-iMac.local"
    public_key = ("~/.ssh/openvpn.pub")
    # ~ means my machine (mac) home directory
}

module "vpn" {
    source  = "terraform-aws-modules/ec2-instance/aws"
    key_name = aws_key_pair.vpn.key_name

    name = "${var.project_name}-${var.environment}-vpn"

    instance_type          = "t2.micro"
    vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
    # convert StringList to list and get first element
    subnet_id              = local.public_subnet_id
    ami = data.aws_ami.ami_info.id
    tags = merge(
        var.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-vpn"
        }
    )
}