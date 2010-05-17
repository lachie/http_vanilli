require 'addressable/uri'
require 'http_vanilli/request'

module HttpVanilli
  class BasicMapper
    class Mapping
      def initialize(method,url,&block)
        @method = method
        @url    = Addressable::URI.heuristic_parse(url)
        @block  = block
      end

      def match?(request)
        (request.host == @url.host).tapp(:match?)
      end

      def response_for_request(request)
        code,headers,body = @block[]

        response      = HttpVanilli::NetHttp::Response.new(code,headers,body)

        nhrsp = response.to_net_http
        request.block[nhrsp] if request.block

        nhrsp
      end
    end

    attr_accessor :mapping_class

    def initialize(mapping_class=Mapping)
      @mapping_class = mapping_class
    end

    def mappings; @mappings ||= [] end

    def build_request(kind,http,request,body,&block)
      HttpVanilli::Request.build(kind,http,request,body,&block)
    end

    def add_mapping(*args,&block)
      mappings << mapping_class.new(*args,&block)
    end

    def map_request?(request)
      mappings.find {|mapping| mapping.match?(request)}
    end

    def map_request(request)
      mapping = map_request?(request)
      mapping.response_for_request(request)
    end

    def unmapped_request(request)
      raise "unmatched_request #{request}"
    end

  end
end
