module HttpVanilli
  module NetHttp
    class Response
      attr_accessor :body, :headers
      attr_reader :code, :message
      def initialize(code,message)
        @code,@message = code,message
        @headers = {}
      end


      def to_net_http
        response = Net::HTTPResponse.send(:response_class, code.to_s).new("1.0", code.to_s, message)

        response.instance_variable_set(:@body, body) if body
        headers.each { |name, value| response[name] = value }

        response.instance_variable_set(:@read, true)
        response.extend HttpVanilli::NetHttp::ResponseMixin

        response
      end
    end
  end
end
