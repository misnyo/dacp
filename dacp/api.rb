#!/usr/bin/ruby
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'grape'
require './dacp'
require 'json'


class API < Grape::API
  get :list do
    Dacp.init(api=true)
    {instances: Dacp.get_list()}
  end
end

class Web < Sinatra::Base
  set :bind, '0.0.0.0'
  set :public_folder, Proc.new { File.join(root, "../static") }

  get "/" do
    send_file File.join(settings.public_folder, 'index.html')
  end
end
