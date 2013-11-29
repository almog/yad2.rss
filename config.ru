require 'rubygems'
require 'bundler'

Bundler.require

require './apartment_search'
run Sinatra::Application
