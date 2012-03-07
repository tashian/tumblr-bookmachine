# Gemfile
$: << File.dirname(__FILE__)

require 'bundler'

Bundler.require

Dir.open("./initializers").each do |file|
    next if file =~ /^\./
      require "./initializers/#{file}"
end

#thes two are the application broken out a bit.
require 'helpers'
require 'models'
require "bookmachine"

set :run, false
set :raise_errors, true

run Sinatra::Application

