require 'addressable/uri'

module HttpVanilli
  class BasicMapper
    attr_accessor :responder

    def initialize(responder)
      self.responder = responder

      #case mapping_class
      #when Hash
        ## XXX setup mapping map
      #when HttpVanilli::BasicMapping
        ## XXX setup single default mapping class
      #end
    end

    def responders; @responders ||= [] end

    def add_responder(*args,&block)
      # XXX switch mapping classes
      responders << responder.new(*args,&block)
    end

    ## Mapping API

    # Take the info from the innards of Net::HTTP and build a request.
    def build_request(kind,http,request,body,&block)
      HttpVanilli::Request.build(kind,http,request,body,&block)
    end

    # Should we map the request?
    def map_request?(request)
      !! find_responder(request)
    end

    # Map the request
    def map_request(request)
      find_responder(request).response_for_request(request)
    end

    # The request wasn't matched and normal net connection was disallowed.
    def unmapped_request(request)
      raise "unmatched_request #{request}"
    end

    protected

    def find_responder(request)
      responders.find {|responder| responder.match?(request)}
    end
  end
end
