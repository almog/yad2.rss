require 'rubygems'
require 'bundler'

Bundler.require

require './apartment_search'

Rack::Handler::Thin.run ApartmentSearch, :Port => 3001
