import 'params.pp'

exec { 'apt-update':
  command => '/usr/bin/apt-get update'
}

#install mysql-server with binding to public
class { '::mysql::server':
  root_password    => $mysql_pw,
  override_options => {
    'mysqld' => { 
      'max_connections' => '1024',
      'bind_address' => '0.0.0.0',
    }
  }
}

#create db for drupal
mysql::db { $mysql_db:
  user     => $mysql_user,
  password => $mysql_user_pw,
  host     => '%',
} 
