require 'pathname'
require 'pp'

class Object
  def tapp(tag=nil)
    print "#{tag}=" if tag
    pp self
    self
  end
end

module HttpVanilli
  autoload :Util   , 'http_vanilli/util'

  autoload :BasicMapper , 'http_vanilli/basic_mapper'
  autoload :BasicMapping, 'http_vanilli/basic_mapping'

  autoload :Request , 'http_vanilli/request'
  autoload :Response, 'http_vanilli/response'

  class << self
    def here
      @here ||= Pathname(__FILE__).dirname
    end

    def override_net_http!
      require here+'http_vanilli/net_http/override'
      HttpVanilli::NetHttp.override!
    end

    def allow_net_connect!
      @allow_net_connect = true
    end

    def disallow_net_connect!
      @allow_net_connect = false
    end

    def allow_net_connect?
      !(FalseClass === @allow_net_connect)
    end

    def basic_mapper!(mapping_class=HttpVanilli::BasicMapping)
      self.request_mapper = BasicMapper.new(mapping_class)
    end

    def request_mapper=(request_mapper)
      @request_mapper = request_mapper
    end

    def request_mapper
      unless @request_mapper
        raise "HttpVanilli requires a request mapper.\n" +
              "Use the basic mapper with HttpVanilli.basic_mapper! ,\n" +
              "or plug one in with HttpVanilli.request_mapper=Yourmapper.new"
      end
      @request_mapper
    end
  end
end
