import 'params.pp'

Ec2_securitygroup {
  region => $region,
}

Ec2_instance {
  region            => $region,
  availability_zone => 'ap-southeast-1b',
}

Elb_loadbalancer {
  region => 'ap-southeast-1',
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

ec2_instance { ["${prefix}web-1"]:
  ensure          => present,
  image_id        => $image_id,
  security_groups => ["${prefix}web-sg"],
  instance_type   => 't2.micro',
  tags            => {
    department => 'engineering',
    project    => 'cloud',
    created_by => $::id,
  },
  key_name	  => $key_name,
  #used to set default ssh port to 222 during boot
  user_data         => template('ssh_user_data.erb')
}

ec2_instance { "${prefix}db-1":
  ensure          => present,
  image_id        => $image_id,
  security_groups => ["${prefix}db-sg"],
  instance_type   => 't2.micro',
  monitoring      => true,
  tags            => {
    department => 'engineering',
    project    => 'cloud',
    created_by => $::id,
  },
  block_devices => [
    {
      device_name => '/dev/sda1',
      volume_size => 8,
    }
  ],
  key_name	  => $key_name,
  #used to set default ssh port to 222 during boot
  user_data         => template('ssh_user_data.erb')
}
