require "rubygems"
require "bundler"

Bundler.require(:default, ENV["RACK_ENV"])

Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|file| require file }
require "./blog"

run Blog
