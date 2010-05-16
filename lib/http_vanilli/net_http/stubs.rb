module HttpVanilli
  module NetHttp
    class StubSocket #:nodoc:

      def initialize(*args)
      end

      def closed?
        @closed ||= true
      end

      def readuntil(*args)
      end

    end

    module ResponseMixin #:nodoc:
      def read_body(*args, &block)
        yield @body if block_given?
        @body
      end

    end
  end
end
