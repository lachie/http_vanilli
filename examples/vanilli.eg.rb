require 'eg_helper'
require 'open-uri'
require 'http_vanilli'
require 'addressable/uri'

require 'pp'
require 'ostruct'

class EgMapper
  def build_request(kind,http,request,body,&block)
    req = OpenStruct.new
    req.block = block

    pp http
    pp request.to_hash

    protocol = http.use_ssl? ? "https" : "http"

    path = request.path
    path = Addressable::URI.parse(request.path).request_uri if request.path =~ /^http/

    req.uri = Addressable::URI.parse( "#{protocol}://#{http.address}:#{http.port}#{path}" )
    req.method = request.method.downcase.to_sym

    req
  end

  def map_request?(request)
    true
  end

  def map_request(request)
    code = 200
    msg = 'cool'

    response = Net::HTTPResponse.send(:response_class, code.to_s).new("1.0", code.to_s, msg)
    response.instance_variable_set(:@body, 'bodacious')
    # headers_extracted_from_options.each { |name, value| response[name] = value }

    response.instance_variable_set(:@read, true)
    response.extend HttpVanilli::NetHttp::Response

    request.block[response] if request.block

    pp response
    response
  end

  def unmapped_request(request)
    raise "unmatched_request :("
  end
end

HttpVanilli.override_net_http!
HttpVanilli.disallow_net_connect!

HttpVanilli.request_mapper = EgMapper.new

eg 'open google.com' do
  open("http://google.com/videos?q=12345&u=6789").read
end
