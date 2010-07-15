require 'addressable/uri'

module HttpVanilli
  class BasicMapper
    attr_accessor :mapping_class

    def initialize(mapping_class=HttpVanilli::Mapping)
      self.mapping_class = mapping_class
    end

    def mappings; @mappings ||= [] end

    def add_mapping(*args,&block)
      mappings << mapping_class.new(*args,&block)
    end

    ## Mapping API

    # Take the info from the innards of Net::HTTP and build a request.
    def build_request(kind,http,request,body,&block)
      HttpVanilli::Request.build(kind,http,request,body,&block)
    end

    # Should we map the request?
    def map_request?(request)
      !! find_mapping(request)
    end

    # Map the request
    def map_request(request)
      find_mapping(request).response_for_request(request)
    end

    # The request wasn't matched and normal net connection was disallowed.
    def unmapped_request(request)
      raise "unmatched_request #{request}"
    end

    protected

    def find_mapping(request)
      mappings.find {|mapping| mapping.match?(request)}
    end
  end
end
