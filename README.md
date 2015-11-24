DACP
=====
Drupal hosting AWS scripts

Quick run
============
* apt-get install puppet ruby ruby-dev
* gem install bundler
* bundle install --path vendor/bundle
* puppet module install puppetlabs-aws
* ./dacp.rb

Docker
======
* cp ~/.aws ./
* docker build -t dacp .
* docker run -t -i dacp /bin/bash
* ./dacp.rb init_puppet
* puppet apply puppet/create.pp --templatedir puppet/templates/

Development
===========
* hooks/apply.sh applies automatic documentation update on every commit to ../dacp-gh-pages/doc for github pages

API
===
* cd dacp
* bundle exec rerun 'bundle exec rackup'
