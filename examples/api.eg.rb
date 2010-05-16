require 'eg_helper'
require 'angry_web/matcher'

class Processor
  def restore(name,value)
    puts "name=#{name} val=#{value}"
    value
  end
end

eg 'matches url greedily' do
  matcher = AngryWeb::Matcher.new do |m|
    m.host /somewhere.com$/
    m.params m.hash_subset(:a => /^x/)
  end

  Show( matcher.match?("somewhere.com/?q=foo&a=xyz") )
  Show( matcher.match?("http://somewhere.com/?a=xyz") )
  Show( matcher.match?("http://somewhere.com/?a=mxyz") )
  Show( matcher.mismatches )
end
