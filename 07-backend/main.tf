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
            "chmod +x /tmp/${var.common_tags.component}.sh",
            "sudo sh /tmp/${var.common_tags.component}.sh ${var.common_tags.component} ${var.environment}"
        ]
    }
}

resource "aws_ec2_instance_state" "backend" {
    instance_id = module.backend.id
    state       = "stopped"
    # stop the server only when null resource provisioning is completed
    depends_on = [ null_resource.backend ]
}

resource "aws_ami_from_instance" "backend" {
    name               = "${var.project_name}-${var.environment}-${var.common_tags.component}"
    source_instance_id = module.backend.id
    depends_on = [ aws_ec2_instance_state.backend ]
}

resource "null_resource" "backend_delete" {
    triggers = {
        instance_id = module.backend.id # this will be triggered everytime instance is created
    }
    connection {
        type        = "ssh"
        user = "ec2-user"
        password = "DevOps321"
        host       = module.backend.private_ip
    }
    
    provisioner "local-exec" {
        command = "aws ec2 terminate-instances --instance-ids ${module.backend.id}"
    }
    depends_on = [ aws_ami_from_instance.backend ]
}

resource "aws_lb_target_group" "backend" {
    name     = "${var.project_name}-${var.environment}-${var.common_tags.component}"
    port     = 8080
    protocol = "HTTP"
    vpc_id   = data.aws_ssm_parameter.vpc_id.value
    health_check {
        path                = "/health"
        port                = 8080
        protocol            = "HTTP"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200"
    }
}