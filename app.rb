# encoding: utf-8
require 'multi_json'
require 'sinatra'
require 'data_mapper'
require 'dm-migrations'
require 'bundler'
require 'instagram'
require 'sinatra/cross_origin'
require 'rmagick'
require 'aws-sdk-v1'
require 'httmultiparty'
require 'base64'
require 'aes'
require 'uri'

require './env' if File.exists?('env.rb')

Bundler.require

include Magick

class Uploader
  include HTTMultiParty
  base_uri 'https://ext.makenewsmail.com/images/'

  def initialize(path, userid, cid)
    @path  = path
    @user_id = userid
    @image_category_id = cid
  end

  def post_img()
    response = Uploader.post("/default_beta.asp?u=#{ @user_id }&cid=#{ @image_category_id }", query: { file: File.new(@path) })
    response.parsed_response['filename']
  end
end

class Makecollage < Sinatra::Application
  enable :sessions

  #CALLBACK_URL = "http://localhost:9292/oauth/callback"
  CALLBACK_URL = "https://make-collage.herokuapp.com/oauth/callback"

  Instagram.configure do |config|
    config.client_id = "4d59549610314d6a9af28bb982ce6cab"
    config.client_secret = "2a8d31557de14184b469985e22c0d01e"
    # For secured endpoints only
    #config.client_ips = '<Comma separated list of IPs>'
  end

  configure :development do
    DataMapper::Logger.new($stdout, :debug)
    DataMapper.setup(
      :default,
      'sqlite:///tmp/my.db'
    )

    enable :cross_origin
  end

  configure :production do
    DataMapper.setup(
      :default,
      'postgres://postgres:12345@localhost/sinatra_service'
    )

    enable :cross_origin
  end
end

require_relative 'helpers/init'
require_relative 'models/init'
require_relative 'routes/init'

DataMapper.finalize
