#aws instance creation
resource "aws_instance" "terraform_ansible_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  availability_zone      = var.availability_zones
  vpc_security_group_ids = var.security_group
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.iam-profile.name
  key_name               = "mykey1802"

  tags = {
    Name        = "${var.environment}-terraform_ansible_server"
    Owner       = var.owner
    Purpose     = var.purpose
    Environment = "${var.environment}"
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    tags = {
      Name        = "${var.environment}-terraform_ansible_ebs"
      Owner       = var.owner
      Purpose     = var.purpose
      Environment = "${var.environment}"
    }
  }

  #   connection {
  #     type        = "ssh"
  #     user        = "root"
  #     private_key = file("/home/rahul/Jhooq/keys/aws/mykey1802")
  #     host        = self.public_ip
  #   }

  #   provisioner "file" {
  #     source      = "./ansible/playbook.yaml"
  #     destination = "/home/ubuntu/playbook.yaml"
  #   }

  #   provisioner "file" {
  #     source      = "./ansible/install.sh"
  #     destination = "/home/ubuntu/install.sh"
  #   }

  #   provisioner "remote-exec" {
  #     inline = [
  #       "chmod +x /home/ubuntu/install.sh",
  #       "/home/ubuntu/install.sh",
  #     ]
  #   }

}

resource "aws_iam_instance_profile" "iam-profile" {
  name = "ec2_profile"
  role = aws_iam_role.iam-role.name
}

resource "aws_iam_role" "iam-role" {
  name        = "dev-ssm-role"
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


