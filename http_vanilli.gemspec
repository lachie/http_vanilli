lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'http_vanilli/version'
 
Gem::Specification.new do |s|
  s.name        = "http_vanilli"
  s.version     = HttpVanilli::Version
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Lachie Cox"]
  s.email       = ["lachiec@gmail.com"]
  s.homepage    = "http://github.com/lachie/http_vanilli"
  s.summary     = "Flexible web connection mocking lib."
  s.description = "HttpVanilli gives you lip-synced http connections with pluggable band members for testing."
 
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "http_vanilli"
 
  s.add_development_dependency "exemplor"
 
  s.files        = Dir.glob("{bin,lib}/**/*") # + %w(LICENSE README.md CHANGELOG.md)
  # s.executables  = ['bundle']
  s.require_path = 'lib'
end
