resource "aws_iam_role" "eks" {
  name = "${var.name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect="Allow", Principal={ Service="eks.amazonaws.com" }, Action="sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = aws_iam_role.eks.arn
  version  = "1.29"

  vpc_config { subnet_ids = var.subnet_ids }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster]
  tags       = var.tags
}

resource "aws_iam_role" "node" {
  name = "${var.name}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect="Allow", Principal={ Service="ec2.amazonaws.com" }, Action="sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy_attachment" "node_worker" { role = aws_iam_role.node.name policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" }
resource "aws_iam_role_policy_attachment" "node_ecr_ro"  { role = aws_iam_role.node.name policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" }
resource "aws_iam_role_policy_attachment" "node_cni"     { role = aws_iam_role.node.name policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" }

resource "aws_eks_node_group" "spot" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "spot"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  scaling_config { desired_size = 0, min_size = 0, max_size = 3 }
  capacity_type  = "SPOT"
  instance_types = ["t3.small","t3a.small","t3.medium","t3a.medium"]

  tags = var.tags
}
