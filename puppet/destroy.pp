import 'params.pp'

Ec2_securitygroup {
  region => $region,
}

Elb_loadbalancer {
  region => 'ap-southeast-1',
}

elb_loadbalancer { "${prefix}lb-1":
  ensure               => absent,
}

ec2_instance { ["${prefix}web-1"]:
  ensure          => absent,
}

ec2_instance { "${prefix}db-1":
  ensure          => absent,
}

ec2_securitygroup { "${prefix}db-sg":
  ensure      => absent,
}

ec2_securitygroup { "${prefix}web-sg":
  ensure      => absent,
}

ec2_securitygroup { "${prefix}lb-sg":
  ensure      => absent,
}
