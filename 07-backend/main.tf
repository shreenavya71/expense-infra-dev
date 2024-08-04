module "backend" {
    source  = "terraform-aws-modules/ec2-instance/aws"

    name = "${var.project_name}-${var.environment}-${var.common_tags.component}"

    instance_type          = "t3.micro"
    vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
    # convert StringList to list and get first element
    subnet_id              = local.private_subnet_id
    ami = data.aws_ami.ami_info.id
    tags = merge(
        var.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-${var.common_tags.component}"
        }
    )
}


resource "null_resource" "backend" {
    triggers = {
        instance_id = module.backend.id # this will be triggered everytime instance is created
    }
    connection {
        type        = "ssh"
        user = "ec2-user"
        password = "DevOps321"
        host       = module.backend.private_ip
    }
    provisioner "file" {
        source      = "${var.common_tags.component}.sh"
        destination = "/tmp/${var.common_tags.component}.sh"
    }
    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/backend.sh",
            "suo sh /tmp/backend.sh ${var.common_tags.component} ${var.common_tags.component} ${var.environment}"
        ]
    }
}
    