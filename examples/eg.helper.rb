require 'rubygems'
require 'bundler'
Bundler.setup

require 'exemplor'
require 'pathname'

root = Pathname('../..').expand_path(__FILE__)
$: << root+"lib"
