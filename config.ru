require "rubygems"
require "bundler"

Bundler.require(:default, ENV["RACK_ENV"])

require "./lib/markdown_renderer"
require "./lib/post"
require "./blog"

run Blog
