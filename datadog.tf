/*
resource "aws_iam_role" "datadog" {
    name = "${var.vpc}-${var.name}-datadog"
    assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "datadog" {
  name = "${var.vpc}-${var.name}-datadog"
  role     = "${aws_iam_role.datadog.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
   {
      "Action": [
        "autoscaling:Describe*",
        "cloudtrail:DescribeTrails",
        "cloudtrail:GetTrailStatus",
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*",
        "ec2:Describe*",
        "ec2:Get*",
        "ecs:Describe*",
        "ecs:List*",
        "elasticache:Describe*",
        "elasticache:List*",
        "elasticloadbalancing:Describe*",
        "iam:Get*",
        "iam:List*",
        "kinesis:Get*",
        "kinesis:List*",
        "kinesis:Describe*",
        "logs:Get*",
        "logs:Describe*",
        "logs:TestMetricFilter",
        "rds:Describe*",
        "rds:List*",
        "ses:Get*",
        "ses:List*",
        "sns:List*",
        "sns:Publish",
        "sqs:GetQueueAttributes",
        "sqs:ListQueues",
        "sqs:ReceiveMessage"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
*/

resource "aws_ecs_task_definition" "datadog" {
  family = "${var.vpc}-${var.name}"
  container_definitions = <<EOF
[
  {
    "name": "${var.vpc}-${var.name}",
    "image": "datadog/docker-dd-agent:ecs",
    "cpu": 10,
    "memory": 128,
    "environment": [{
      "name" : "API_KEY",
      "value" : "${var.api_key}"
    }],
    "mountPoints": [{
      "sourceVolume": "docker-sock", 
      "containerPath": "/var/run/docker.sock", 
      "readOnly": false
    },{
      "sourceVolume": "proc", 
      "containerPath": "/host/proc", 
      "readOnly": true
    },{
      "sourceVolume": "cgroup", 
      "containerPath": "/host/sys/fs/cgroup", 
      "readOnly": true
    }] 
  }
]
EOF
  volume {
    name = "docker-sock"
    host_path = "/var/run/docker.sock"
  }
  volume {
    name = "proc"
    host_path = "/proc/"
  }
  volume {
    name = "cgroup"
    host_path = "/cgroup/"
  }
}

resource "aws_ecs_service" "datadog" {
  name = "${var.vpc}-${var.name}"
  cluster = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.datadog.arn}"
  desired_count = "${var.desired_count}"
}
