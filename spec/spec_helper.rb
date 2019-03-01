# Configuration for acceptance tests

# Set the environment to 'test' to use correct settings in config/environment
ENV['RACK_ENV'] = 'test'

# Use bundler to load gems
require 'bundler'

# Load gems from Gemfile
Bundler.require

# Load the environment
require_relative '../config/environment'
require_relative '../app'
require_relative './helper_class.rb'
require 'capybara/rspec'

Capybara.app = App
Capybara.server = :webrick
#Capybara.app_host = 'http://localhost:'

Capybara.default_driver = :selenium_chrome #:selenium_chrome_headless are also registered

Helper.populate_user_table
# TODO: Create testing for manage account
