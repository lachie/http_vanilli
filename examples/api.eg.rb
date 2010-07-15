require 'eg.helper'
require 'http_vanilli'

require 'open-uri'
require 'addressable/uri'

HttpVanilli.disallow_net_connect!
HttpVanilli.override_net_http!

class EgMapping
  include HttpVanilli::NetHttp::ResponseYield

  def initialize(method,url,&block)
    @method = method
    @url    = Addressable::URI.heuristic_parse(url)
    @block  = block
  end

  def match?(request)
    (request.host == @url.host)
  end

  def response_for_request(request)
    response = HttpVanilli::NetHttp::Response.new(*@block.call)

    yield_response(response,request)
  end

end

eg.setup do
  @m = HttpVanilli.request_mapper = HttpVanilli::BasicMapper.new #(EgMapping)
end

eg 'a simple mapping' do
  @m.add_mapping(:get, "http://google.com") { [200, {'content-type' => 'text/smileys'}, ["wikid"]] }
  Assert( open("http://google.com").read == 'wikid' )
end
