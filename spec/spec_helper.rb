require 'webmock/rspec'
require File.expand_path('../../lib/remote_resource', __FILE__)

RSpec.configure do |config|
  config.order = 'random'
end
