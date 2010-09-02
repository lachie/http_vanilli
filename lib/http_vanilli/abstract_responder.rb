module HttpVanilli
  module AbstractResponder
    include HttpVanilli::NetHttp::YieldResponse

    def response_for_request(request)
      code,headers,body = *rack_response(request)

      response = HttpVanilli::NetHttp::Response.new(code,headers,body)

      nh_yield_response(response,request)
    end
  end
end
