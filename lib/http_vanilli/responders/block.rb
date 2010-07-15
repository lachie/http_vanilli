module HttpVanilli
  module Responders
    class Block
      include HttpVanilli::AbstractResponder

      def initialize(&block)
        @block = block
      end

      def match?(request)
        !! @block[request]
      end

      def rack_response(request)
        @block[request]
      end
    end
  end
end
