#aws instance creation
resource "aws_instance" "terraform_ansible_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  availability_zone      = var.availability_zones
  vpc_security_group_ids = [aws_security_group.tfc_ansible_sg.id]
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.iam-profile.name
  key_name               = "deployer-key"

  tags = {
    Name        = "${var.environment}-terraform_ansible_server"
    Owner       = var.owner
    Purpose     = var.purpose
    Environment = "${var.environment}"
  }

  root_block_device {
    delete_on_termination = true
    tags = {
      Name        = "${var.environment}-terraform_ansible_ebs"
      Owner       = var.owner
      Purpose     = var.purpose
      Environment = "${var.environment}"
    }
  }

  connection {
    type     = "ssh"
    user     = "user01"
    password = var.user_password
    host     = self.public_ip
  }

  provisioner "file" {
    source      = "./ansible/inventory.yaml"
    destination = "/home/inventory.yaml"
  }

  provisioner "file" {
    source      = "./ansible/templates/site.conf.j2.cfg"
    destination = "/home/templates/site.conf.j2.cfg"
  }

  provisioner "file" {
    source      = "./ansible/nginx.yaml"
    destination = "/home/nginx.yaml"
  }


  provisioner "file" {
    source      = "./ansible/site/index.html"
    destination = "/home/site/index.html"
  }
  provisioner "file" {
    source      = "./ansible/sync.yaml"
    destination = "/home/sync.yaml"
  }

  provisioner "file" {
    source      = "./ansible/install.sh"
    destination = "/home/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/install.sh",
      "/home/install.sh",
    ]
  }

}

resource "aws_iam_instance_profile" "iam-profile" {
  name = "ec2_tfc_ansible_profile"
  role = aws_iam_role.iam-role.name
}

resource "aws_iam_role" "iam-role" {
  name        = "terraform-ansible-ssm-role"
  description = "The role for the developer resources EC2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "${var.environment}-iam-instance-profile"
    Owner       = var.owner
    Purpose     = var.purpose
    Environment = "${var.environment}"
  }
}

resource "aws_iam_role_policy_attachment" "ssm-policy" {
  role       = aws_iam_role.iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_security_group" "tfc_ansible_sg" {
  name        = "terraform-ansible-security-group"
  description = "Security Group for terraform-ansible server"
  vpc_id      = var.vpc_id

  ingress {
    description = "inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-web-server-security-group"
    Owner       = var.owner
    Purpose     = var.purpose
    Environment = "${var.environment}"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDDOGMh6Yjw7peHcKVuU4mw03E/f+yIOhzcclmG+DpdHbB+whewXl6XlvH/fAtlvC0cDVPLH9ggbV0itpanFffmi0LDuWOuQ5/fJK0E/Zzgb1IsJf/w5pjkepeg3CXPMiE6uIq7P1uekrmNwRLX9pI+TTsqrXeb1tF4SZ6hLZjoMOa48tbfBtr3os1S5bR+uRdQJA+qMY4sylEDWrwJDBJs+b0GpH1T9eoVbE048xQurolcHqfIWuR3OjKPnEmzG6CnPgzgrnydpouDWqf1HeGEIcig8W1yZxl13Uv/1x4p6ILBQJvOFBJLKd56LvCE+NCaiPPwGXiZZg9r5ixTUFOpzHyR6pGH5DT17nMfCxhI7Ce515dIFXIOfpds9FlDqJ8JIq8vNwQNW3fZv7CgMVM2deNlzA+iWEfWQZz2pxtGbY0jMsYhOA2FME21z3tgS0M8zYXtqCi1nr3eMGL+7+/QyJOuurFx4+hlHVE1J4sALR6Gn85LfRVLQOu7U+M8rA1yelfZQDz3/2EGZMR2FjjmfdjmlX8tl/ilN7+PRXCMi8PNHe9iGSQGY8n2zYuHYT3fqbGX4z3bqWPgX0qMcSClzF+fbIbBHtjhzJjJH0vgUdqKHn8adNKKscgCezpLPMl+tHhKL6TLNkeTt2sutv3kL0/HR2Zu62Pm/4mK4XRlxQ== zhihao.pang@zhihao.pang-X1R93MXMGV"
}