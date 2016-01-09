Ec2_securitygroup {
  region => $region,
}

ec2_securitygroup { "${prefix}lb-sg":
  ensure      => present,
  description => 'Security group for load balancer',
  ingress     => [{
    protocol => 'tcp',
    port     => 80,
    cidr     => '0.0.0.0/0'
  }],
}

ec2_securitygroup { "${prefix}web-sg":
  ensure      => present,
  description => 'Security group for web servers',
  ingress     => [{
    security_group => "${prefix}lb-sg",
  },{
    protocol => 'tcp',
    port     => 222,
    cidr     => '0.0.0.0/0'
  }],
}

ec2_securitygroup { "${prefix}db-sg":
  ensure      => present,
  description => 'Security group for database servers',
  ingress     => [{
    security_group => "${prefix}web-sg",
  },{
    protocol => 'tcp',
    port     => 222,
    cidr     => '0.0.0.0/0'
  }],
}
