#aws instance creation
resource "aws_instance" "terraform_ansible_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  availability_zone      = var.availability_zones
  vpc_security_group_ids = [aws_security_group.tfc_ansible_sg.id]
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.iam-profile.name

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
