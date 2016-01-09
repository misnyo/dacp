import 'params.pp'
import 'aws_sg.pp'

ec2_instance { "${prefix}db-1":
  ensure          => present,
  image_id        => $image_id,
  security_groups => ["${prefix}db-sg"],
  instance_type   => 't2.micro',
  monitoring      => true,
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
