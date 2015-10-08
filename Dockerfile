FROM ubuntu:14.04
RUN \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y ruby git ruby-bundler puppet

ADD dacp.rb /root/dacp/dacp.rb
ADD config /root/dacp/config
ADD Gemfile /root/dacp/Gemfile
ADD .aws /root/.aws
ADD puppet /root/dacp/puppet

ENV HOME /root
WORKDIR /root

RUN \
    cd /root/dacp && \
    bundle install && \
    puppet module install puppetlabs-aws && \
    ./dacp.rb

CMD ["bash"]
