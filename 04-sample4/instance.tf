resource "aws_instance" "sample_ec2" {
  for_each = var.instance_names
  ami           = data.aws_ami.devops_practice.id
  instance_type = each.key == "mongodb" ? "t3.medium" : "t2.micro"
  security_groups = [aws_security_group.allow_all.name]
  tags = {
    Name = each.key
  }
}

resource "aws_route53_record" "wroboshop_route" {
  for_each = aws_instance.sample_ec2
  zone_id = var.zone_id
  name    ="${each.key}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [each.key == "web" ? each.value.public_ip :  each.value.private_ip]
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all traffic"

 dynamic ingress {
    for_each = var.ingress
    content {
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
    }
  }
 
 dynamic egress {
    for_each = var.egress
    content {
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "allow_all"
  }
  
}