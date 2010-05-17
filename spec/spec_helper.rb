require 'rubygems'
require 'spec'
require 'pathname'

root = Pathname(__FILE__).dirname.parent
$: << root+"lib"

Spec::Runner.configure do |config|
end
