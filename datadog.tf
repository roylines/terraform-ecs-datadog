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
