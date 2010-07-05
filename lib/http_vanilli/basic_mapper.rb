require 'addressable/uri'
require 'ostruct'
require 'pp'

module HttpVanilli
  class BasicMapper
    def customise_request(&block)
      @customise_request = block
    end

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

      if @customise_request
        @customise_request[req]
      end

      req
    end

    def map_request?(request)
      true
    end

    def map_request(request)
      response = HttpVanilli::NetHttp::Response.new(200,'cool')
      response.body = "boddy"

      nhrsp = response.to_net_http
      request.block[nhrsp] if request.block

      nhrsp
    end

    def unmapped_request(request)
      raise "unmatched_request :("
    end
  end
end
