require 'http_vanilli/net_http/stubs'
require 'http_vanilli/net_http/util'
require 'http_vanilli/net_http/request'
require 'http_vanilli/net_http/response'
require 'net/http'
require 'net/https'
require 'stringio'

module HttpVanilli
  module NetHttp
    def self.override!
      record_loaded_net_http_replacement_libs
      puts_warning_for_net_http_around_advice_libs_if_needed
    end
  end
end

module Net  #:nodoc: all
  class BufferedIO
    def initialize_with_http_vanilli(io, debug_output = nil)
      @read_timeout = 60
      @rbuf = ''
      @debug_output = debug_output

      @io = case io
      when Socket, OpenSSL::SSL::SSLSocket, IO
        io
      when String
        if !io.include?("\0") && File.exists?(io) && !File.directory?(io)
          File.open(io, "r")
        else
          StringIO.new(io)
        end
      end
      raise "Unable to create local socket" unless @io
    end
    alias_method :initialize_without_http_vanilli, :initialize
    alias_method :initialize, :initialize_with_http_vanilli
  end

  class HTTP
    # add some class methods
    class << self
      def socket_type_with_http_vanilli
        HttpVanilli::NetHttp::StubSocket
      end
      alias_method :socket_type_without_http_vanilli, :socket_type
      alias_method :socket_type, :socket_type_with_http_vanilli

      def last_request_index
        @last_request_index ||= -1
      end

      def next_request_index
        @last_request_index ||= -1
        @last_request_index += 1
      end
    end

    def request_with_http_vanilli(request, body = nil, &block)
      mapper = HttpVanilli.request_mapper

      request.set_body_internal body

      # Wrap Net::HTTPRequest & associated info in a HttpVanilli::Request
      vanilli_request = mapper.build_request(:net_http, self, request, self.class.next_request_index, &block)

      # The mapper can map the request. Do it.
      if mapper.map_request?(vanilli_request)
        @socket = Net::HTTP.socket_type.new
        mapper.map_request(vanilli_request)

      # otherwise, either allow the request to happen as normal,
      elsif HttpVanilli.allow_net_connect?
        connect_without_http_vanilli
        request_without_http_vanilli(request, body, &block)

      # or note the request as unmapped.
      else
        mapper.unmapped_request(vanilli_request)
      end
    end
    alias_method :request_without_http_vanilli, :request
    alias_method :request, :request_with_http_vanilli


    def connect_with_http_vanilli
      unless @@alredy_checked_for_net_http_replacement_libs ||= false
        HttpVanilli::NetHttp.puts_warning_for_net_http_replacement_libs_if_needed
        @@alredy_checked_for_net_http_replacement_libs = true
      end
      nil
    end
    alias_method :connect_without_http_vanilli, :connect
    alias_method :connect, :connect_with_http_vanilli
  end

end
