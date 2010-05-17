module HttpVanilli
  class Request
    def self.build(kind,*args,&block)
      case kind
      when :net_http
        HttpVanilli::NetHttp::Request.new(*args,&block)
      else
        raise "Unknown request kind #{kind}"
      end
    end
  end
end
