import 'drupalparams.pp'

exec { 'apt-update':
  command => '/usr/bin/apt-get update'
}

package { 'apache2':
  require => Exec['apt-update'],
  ensure => installed,
}

package { 'sendmail':
  require => Exec['apt-update'],
  ensure => installed,
}

service { 'apache2':
  ensure => running,
}

exec { 'enable rewrite':
  command => '/usr/sbin/a2enmod rewrite',
  notify => Service[apache2],
  require => Package['apache2'],
}

package { 'php5':
  require => Exec['apt-update'],
  ensure => installed,
}

package { 'php5-mysql':
  require => Exec['apt-update'],
  ensure => installed,
}

package { 'php5-gd':
  require => Exec['apt-update'],
  ensure => installed,
}

package { 'mysql-client':
  require => Exec['apt-update'],
  ensure => installed,
}

package { 'curl':
  require => Exec['apt-update'],
  ensure => installed,
}

file { '/var/www/html/info.php':
  ensure => file,
  content => '<?php  phpinfo(); ?>',
  require => Package['apache2'],
} 

exec { 'install composer':
  command => '/usr/bin/curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer',
  creates => '/usr/local/bin/composer',
  require => [ Package['php5'], Package['curl'] ],
  user => 'ubuntu',
}

exec { 'install drush':
  command => '/usr/local/bin/composer global require drush/drush:7.*',
  creates => '/home/ubuntu/.composer/vendor/bin/drush',
  require => Exec['install composer'],
  user => 'ubuntu',
  environment => ["HOME=/home/ubuntu"],
  path    => '/usr/bin:/usr/local/bin:/home/ubuntu/.composer/vendor/bin/',
  cwd => '/home/ubuntu',
}

exec { 'export composer':
  command => '/bin/echo "export PATH=\\"\\$HOME/.composer/vendor/bin:\\$PATH\\" >> /home/ubuntu/.bash_profile',
  onlyif => '/bin/grep composer /home/ubuntu/.bash_profile',
  require => Exec['install composer'],
  user => 'ubuntu',
}

exec { 'download drupal':
  command => '/home/ubuntu/.composer/vendor/bin/drush dl -y --destination="/var/www"  --drupal-project-rename="html" drupal-7.x',
  require => Exec['install drush'],
}

#exec { 'move drupal':
#  command => '/bin/mv /home/ubuntu/drupal/* /var/www/html',
#  require => Exec['download drupal'],
#}

exec { 'install drupal':
  command => "/home/ubuntu/.composer/vendor/bin/drush site-install standard -y --account-name=admin --account-pass=admin --db-url=$drupal_db_url --account-mail=misnyo@msinyo.eu",
  require => [ Exec['download drupal'], Package['sendmail'] ],
  cwd => '/var/www/html',
}