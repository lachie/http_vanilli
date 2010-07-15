require 'addressable/uri'

module HttpVanilli
  class BasicMapper
    attr_accessor :mapping_class

    def initialize(mapping_class)
      self.mapping_class = mapping_class
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
      mapping.build_response(request)
    end

    def unmapped_request(request)
      raise "unmatched_request #{request}"
    end

  end
end
