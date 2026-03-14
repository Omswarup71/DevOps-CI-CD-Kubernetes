# SERVER2: 'NODE-SERVER' (Docker + Kubernetes)

# STEP1: SECURITY GROUP FOR K8S NODE
resource "aws_security_group" "my_security_group2" {
  name        = "my-security-group2"
  description = "Allow Kubernetes ports"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8001
    to_port   = 8001
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 10250
    to_port   = 10250
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 30000
    to_port   = 32767
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# STEP2: CREATE K8S EC2 INSTANCE
resource "aws_instance" "my_ec2_instance2" {

  ami           = "ami-0c02fb55956c7d316"
  instance_type = "c7i-flex.large"

  vpc_security_group_ids = [aws_security_group.my_security_group2.id]
  key_name               = "My_Key"

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "NODE-SERVER"
  }

  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      private_key = file("./My_Key.pem")
      user        = "ec2-user"
      host        = self.public_ip
    }

    inline = [

      "sleep 300",

      # Update system
      "sudo yum update -y",

      # Install Docker
      "sudo yum install docker -y",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ec2-user",

      # Disable SELinux
      "sudo setenforce 0",
      "sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config",

      # Kubernetes repo
      "echo '[kubernetes]' | sudo tee /etc/yum.repos.d/kubernetes.repo",
      "echo 'name=Kubernetes' | sudo tee -a /etc/yum.repos.d/kubernetes.repo",
      "echo 'baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/' | sudo tee -a /etc/yum.repos.d/kubernetes.repo",
      "echo 'enabled=1' | sudo tee -a /etc/yum.repos.d/kubernetes.repo",
      "echo 'gpgcheck=1' | sudo tee -a /etc/yum.repos.d/kubernetes.repo",
      "echo 'gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key' | sudo tee -a /etc/yum.repos.d/kubernetes.repo",
      "echo 'exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni' | sudo tee -a /etc/yum.repos.d/kubernetes.repo",

      # Install Kubernetes
      "sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes",
      "sudo systemctl enable kubelet",
      "sudo systemctl start kubelet",

      # Initialize cluster
      "sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU --ignore-preflight-errors=Mem",

      # Configure kubectl
      "mkdir -p $HOME/.kube",
      "sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",

      # Install Calico
      "kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml",

      # Allow pods on control-plane
      "kubectl taint nodes --all node-role.kubernetes.io/control-plane-"
    ]
  }
}

# OUTPUTS

output "NODE_SERVER_PUBLIC_IP" {
  value = aws_instance.my_ec2_instance2.public_ip
}

output "NODE_SERVER_PRIVATE_IP" {
  value = aws_instance.my_ec2_instance2.private_ip
}