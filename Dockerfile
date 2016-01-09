FROM ubuntu:14.04
RUN \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y ruby git ruby-bundler puppet wget

ADD Gemfile /root/dacp/Gemfile

ENV HOME /root
WORKDIR /root

RUN \
    cd /root/dacp && \
    bundle install
RUN \
    wget https://github.com/misnyo/puppetlabs-aws/archive/elb_sg_fix.tar.gz -O /tmp/puppetlabs-aws-1.3.0-a.tar.gz && \
    puppet module install --force --ignore-dependencies /tmp/puppetlabs-aws-1.3.0-a.tar.gz

ADD .aws /root/.aws
ADD dacp /root/dacp
ADD puppet /root/puppet

RUN cd /root/dacp && ./dacp.rb
