#!/usr/bin/ruby
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'grape'
require './dacp'
require 'json'


class API < Grape::API
  format :json
  prefix :api

  get :config do
    Dacp.init(api=true)
    {config: Dacp.get_config()}
  end

  get :list do
    Dacp.init(api=true)
    {instances: Dacp.get_list(), dns: Dacp.get_dns()}
  end

  get :enroll_cluster do
    Dacp.init(api=true)
    Dacp.run_enroll_cluster()
    {message: "cluster enrolled"}
  end

  get :destroy_cluster do
    Dacp.init(api=true)
    Dacp.run_destroy_cluster()
    {message: "cluster destroyed"}
  end

  params do
    requires :id, type: String
  end
  get '/instance/start/:id' do
    Dacp.run_start(params[:id])        
  end

  params do
    requires :id, type: String
  end
  get '/instance/stop/:id' do
    Dacp.run_stop(params[:id])        
  end
end

class Web < Sinatra::Base
  set :bind, '0.0.0.0'
  set :public_folder, Proc.new { File.join(root, "../static") }

  get "/" do
    send_file File.join(settings.public_folder, 'index.html')
  end
end
