import 'drupalparams.pp'

exec { 'apt-update':
  command => '/usr/bin/apt-get update'
}

package { 'apache2':
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

file { '/var/www/html/info.php':
  ensure => file,
  content => '<?php  phpinfo(); ?>',
  require => Package['apache2'],
} 

exec { 'install composer':
  command => 'curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer',
  creates => '/usr/local/bin/composer',
  require => Package['php5'],
  user => 'ubuntu',
}

exec { 'install drush':
  command => 'composer global require drush/drush:7.*',
  creates => '~/.composer/vendor/bin/drush',
  require => Exec['install composer'],
  user => 'ubuntu',
}

exec { 'export composer':
  command => 'echo "export PATH=\\"\\$HOME/.composer/vendor/bin:\\$PATH\\"' >> ~/.bash_profile',
  onlyif => 'grep composer ~/.bash_profile',
  require => Exec['install composer'],
  user => 'ubuntu',
}

exec { 'download drupal':
  command => 'drush dl --bare --destination="drupal" drupal-7.x',
  require => Exec['install drush'],
  user => 'ubuntu',
}

exec { 'move drupal':
  command => 'sudo mv drupal/* /var/www/html'
  require => Exec['dowload drupal'],
  user => 'ubuntu',
}

exec { 'install drupal':
  command => "drush site-install standard -y --account-name=admin --account-pass=admin --db-url=$drupal_db_url",
  require => Exec['move drupal',
  user => 'ubuntu'
}
