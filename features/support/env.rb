require 'capybara'
require 'capybara/cucumber'
require 'capybara/minitest'

Capybara.configure do |config|
  config.default_driver = :selenium_chrome
  config.app_host = 'localhost:9292'
end

require 'minitest/spec'

class MinitestWorld
  include Minitest::Assertions
  attr_accessor :assertions

  def initialize
    self.assertions = 0
  end
end

World do
  MinitestWorld.new
end
