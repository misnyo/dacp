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

ADD config /root/dacp/config
ADD .aws /root/.aws
ADD dacp.rb /root/dacp/dacp.rb
ADD dacpinstance.rb /root/dacp/dacpinstance.rb
ADD puppet /root/dacp/puppet

RUN cd /root/dacp && ./dacp.rb
