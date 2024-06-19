resource "aws_security_group" "eks_cluster" {
  name = "eks-cluster-sgroup1"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    
  }

   ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "demo" {
  name = "eks-cluster-demo3"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "demo-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo.name
}


resource "aws_iam_role_policy_attachment" "demo-ec2-container" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess" 
  role       = aws_iam_role.demo.name
}



resource "aws_eks_cluster" "demo" {
  name     = "ramit_democluster1"
  role_arn = aws_iam_role.demo.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    security_group_ids      = [aws_security_group.eks_cluster.id]
    subnet_ids = [
      aws_subnet.private-us-east-1a.id,
      aws_subnet.private-us-east-1b.id,
      aws_subnet.public-us-east-1a.id,
      aws_subnet.public-us-east-1b.id
    ]
    endpoint_private_access = "true"
    endpoint_public_access  = "true"
  }
  depends_on = [
    aws_iam_role_policy_attachment.demo-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.demo-ec2-container
    
    ]

  // Cluster Tags
  tags = {
    Name             = "ramit_demo-cluster-1234"
    environment      = "non-prod"
    ppm_id           = "PRJ-1234"
  }

}


