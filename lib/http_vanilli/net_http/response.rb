module HttpVanilli
  module NetHttp
    module ResponseYield
      def yield_response(response,request)
        nh_rsp = response.to_net_http
        request.block[nh_rsp] if request.block
        nh_rsp
      end
    end

    class Response < HttpVanilli::Response
      attr_accessor :headers, :body
      attr_reader :code, :message

      def initialize(code,headers,body,message=StatusMessage[code.to_i])
        @code,@body,@message = code.to_i,body,message
        @headers = headers || {}
      end

      def body
        @body.join("")
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
