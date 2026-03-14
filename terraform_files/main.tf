# SERVER1: 'MASTER-SERVER' (Jenkins, Maven, Docker, Ansible, Trivy)

# STEP1: SECURITY GROUP FOR JENKINS SERVER
resource "aws_security_group" "my_security_group1" {
  name        = "my-security-group1"
  description = "Allow SSH, HTTP, HTTPS, Jenkins"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# STEP2: CREATE JENKINS EC2 INSTANCE
resource "aws_instance" "my_ec2_instance1" {

  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "c7i-flex.large"
  vpc_security_group_ids = [aws_security_group.my_security_group1.id]
  key_name               = "My_Key"

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "MASTER-SERVER"
  }

  user_data = <<-EOF
#!/bin/bash
sleep 60
yum update -y
yum install -y git java-17-amazon-corretto maven
EOF

  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      private_key = file("./My_Key.pem")
      user        = "ec2-user"
      host        = self.public_ip
    }

    inline = [

      "sleep 300",

      # Install Jenkins
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key",
      "sudo yum install jenkins -y",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",

      # Install Docker
      "sudo yum install docker -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ec2-user",
      "sudo usermod -aG docker jenkins",

      # Install Trivy
      "sudo rpm -ivh https://github.com/aquasecurity/trivy/releases/latest/download/trivy_0.50.0_Linux-64bit.rpm",

      # Install Ansible
      "sudo yum install python3-pip -y",
      "pip3 install ansible"
    ]
  }
}

# OUTPUTS

output "ACCESS_YOUR_JENKINS_HERE" {
  value = "http://${aws_instance.my_ec2_instance1.public_ip}:8080"
}

output "Jenkins_Initial_Password" {
  value = "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
}

output "MASTER_SERVER_PUBLIC_IP" {
  value = aws_instance.my_ec2_instance1.public_ip
}

output "MASTER_SERVER_PRIVATE_IP" {
  value = aws_instance.my_ec2_instance1.private_ip
}