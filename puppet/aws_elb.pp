import 'params.pp'
import 'aws_sg.pp'

Elb_loadbalancer {
  region => "${region}",
  security_groups => ["${prefix}lb-sg"],
}

elb_loadbalancer { "${prefix}lb-1":
  ensure               => present,
  availability_zones   => ["${region}b"],
  instances            => ["${prefix}web-1"],
  listeners            => [{
    protocol           => 'tcp',
    load_balancer_port => 80,
    instance_protocol  => 'tcp',
    instance_port      => 80,
  }],
  health_check         => {
    target             => 'HTTP:80/robots.txt',
    interval           => 10,
    timeout            => 5,
    healthy_threshold  => 3,
    unhealthy_threshold => 3,
  },
}
