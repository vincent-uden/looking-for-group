require 'capybara'
require 'capybara/dsl'
require 'sinatra'
require 'bundler'

Bundler.require

#require_relative '../app'

Capybara.app = Sinatra::Application
Capybara.app_host = "http://localhost:9292"
Capybara.server_host = "localhost"
Capybara.server_port = "92929"

RSpec.configure do |config|
  config.include Capybara::DSL
end
