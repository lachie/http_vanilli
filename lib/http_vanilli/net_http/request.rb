require 'http_vanilli/request'

module HttpVanilli
  module NetHttp
    class Request < HttpVanilli::Request
      attr_reader :block, :uri, :method

      def initialize(http,request,body=nil,&block)
        @http             = http
        @original_request = request
        @block            = block
        @body             = body

        protocol = http.use_ssl? ? "https" : "http"

        path = request.path
        path = Addressable::URI.parse(request.path).request_uri if request.path =~ /^https?:/

        @uri    = Addressable::URI.parse( "#{protocol}://#{http.address}:#{http.port}#{path}" )
        @method = request.method.downcase.to_sym
      end

      def host; @uri.host end

      def to_s
        "#{@method} #{@uri.to_s}"
      end
    end
  end
end
