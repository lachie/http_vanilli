module HttpVanilli
  module Responders
    class Rack
      include HttpVanilli::AbstractResponder

      def initialize(app_class,*args,&block)
        @app_class = app_class
        @args = args
        @block = block
      end

      BadStatus = 999
      def match?(request)
        rsp = rack_response(request)
        rsp.first != BadStatus
      end

      def rack_response(request)
        uri = request.uri

        env = {
          'REQUEST_METHOD' => request.original_request.method,
          
          # this'll to for now
          'SCRIPT_NAME'    => "",
          'PATH_INFO'      => uri.path,

          'QUERY_STRING'   => uri.query,
          'SERVER_NAME'    => uri.host,
          'SERVER_PORT'    => uri.port
        }

        request.original_request.each_header {|k,v|
          env["HTTP_#{k.upcase}"] = v
        }

        rack_input = StringIO.new((request.body || '').to_s)
        rack_input.set_encoding(Encoding::BINARY) if rack_input.respond_to?(:set_encoding)

        env.update({"rack.version" => [1,1],
                     "rack.input"  => rack_input,
                     "rack.errors" => $stderr,

                     "rack.multithread"  => true,
                     "rack.multiprocess" => false,
                     "rack.run_once"     => false,

                     "rack.url_scheme" => request.uri.scheme
                   })

        app.call(env)
      end

      def app
        inner_app = lambda {|l| [BadStatus,{'Content-Type' => 'text/plain'},['']]}
        @app_class.new(inner_app,*@args,&@block)
      end
    end
  end
end

