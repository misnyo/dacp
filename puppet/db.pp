import 'params.pp'

# execute 'apt-get update'
exec { 'apt-update':                    # exec resource named 'apt-update'
  command => '/usr/bin/apt-get update'  # command this resource will run
}

class { '::mysql::server':
  root_password    => $mysql_pw,
  override_options => { 'mysqld' => { 'max_connections' => '1024' } }
}
