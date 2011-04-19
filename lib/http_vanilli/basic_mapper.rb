require 'addressable/uri'

module HttpVanilli
  class BasicMapper
    attr_accessor :responder

    def initialize(extra_responders = {})
      responder_classes.update(extra_responders)
    end

    def responder_classes
      @responder_classes ||= {
        :block => HttpVanilli::Responders::Block,
        :rack  => HttpVanilli::Responders::Rack
      }
    end

    def responders; @responders ||= [] end

    def add_block_responder(*args,&block)
      responders << responder_classes[:block].new(*args,&block)
    end

    def add_rack_responder(*args,&block)
      responders << responder_classes[:rack].new(*args,&block)
    end

    def add_responder(kind,*args,&block)
      responders << responder_classes[kind].new(*args,&block)
    end

    ## Mapping API

    # Take the info from the innards of Net::HTTP and build a request.
    def build_request(kind, http, request, index, &block)
      HttpVanilli::Request.build(kind, http, request, index, &block)
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
