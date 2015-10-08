FROM ubuntu:14.04
RUN \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y ruby git ruby-bundler puppet

ADD Gemfile /root/dacp/Gemfile

ENV HOME /root
WORKDIR /root

RUN \
    cd /root/dacp && \
    bundle install && \
    puppet module install puppetlabs-aws

ADD .aws /root/.aws
ADD dacp /root/dacp
ADD puppet /root/puppet

RUN cd /root/dacp && ./dacp.rb
