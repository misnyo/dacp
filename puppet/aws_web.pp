import 'params.pp'
import 'aws_sg.pp'

ec2_instance { ["${prefix}web-1"]:
  ensure          => present,
  image_id        => $image_id,
  monitoring      => 'false',
  security_groups => ["${prefix}web-sg"],
  instance_type   => 't2.micro',
  key_name	  => $key_name,
  #used to set default ssh port to 222 during boot
  user_data         => template('ssh_user_data.erb')
}
