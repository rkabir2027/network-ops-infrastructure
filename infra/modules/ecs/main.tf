
# 1. ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

# 2. CloudWatch log group
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-task"
  retention_in_days = 7
}

# 3. ECS task execution role
resource "aws_iam_role" "execution" {
  name = "${var.project_name}-terraform-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Permissions to pull images and write logs
resource "aws_iam_role_policy_attachment" "execution" {
  role = aws_iam_role.execution.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 4. Application task role
resource "aws_iam_role" "task" {
  name = "${var.project_name}-terraform-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# 5. ECS security group
resource "aws_security_group" "ecs" {
  name_prefix = "${var.project_name}-ecs-"
  description = "Allow ECS traffic from ALB only"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-ecs-sg"
  }
}

# Only the ALB can reach container port 8080
resource "aws_vpc_security_group_ingress_rule" "from_alb" {
  security_group_id = aws_security_group.ecs.id

  referenced_security_group_id = var.alb_security_group_id

  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"
}

# Allow ECS to reach ECR and AWS services
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.ecs.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# 6. Fargate task definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.execution.arn
  task_role_arn      = aws_iam_role.task.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-app"
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# 7. ECS Fargate service
resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn

  desired_count = var.desired_count
  launch_type   = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.project_name}-app"
    container_port   = 8080
  }

  health_check_grace_period_seconds = 60

  depends_on = [
    aws_iam_role_policy_attachment.execution
  ]
}
