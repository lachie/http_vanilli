require 'eg.helper'
require 'http_vanilli'

require 'open-uri'
require 'addressable/uri'

HttpVanilli.disallow_net_connect!
HttpVanilli.override_net_http!

class EgResponder
  include HttpVanilli::AbstractResponder

  def initialize(method,url,&block)
    @method = method
    @url    = Addressable::URI.heuristic_parse(url)
    @block  = block
  end

  def match?(request)
    (request.host == @url.host)
  end

  def rack_response(request)
    @block[request]
  end
end


eg.setup do
  @m = HttpVanilli.use_basic_mapper!(EgResponder)
end

eg 'a simple mapping' do
  @m.add_responder(:get, "http://google.com") { [200, {'content-type' => 'text/smileys'}, ["wikid"]] }
  Assert( open("http://google.com").read == 'wikid' )
end

#eg 'a complex mapping' do
 #@m.add_responder(:get, "http:/youtube.com") {|req|
    #puts "mapping r=#{req.inspect}"
 #}

 #Show( open("http://youtube.com?v=12345&mode=channel") )
 ## Show( open("http://google.com") )
#end
