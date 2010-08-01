require 'http_vanilli/request'

module HttpVanilli
  module NetHttp
    class Request < HttpVanilli::Request
      attr_reader :block, :uri, :method, :original_request

      def initialize(http,request,&block)
        @http             = http
        @original_request = request
        @block            = block

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

      def body
        @original_request.body
      end
    end
  end
end
