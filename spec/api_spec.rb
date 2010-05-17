require 'spec_helper'
require 'http_vanilli/test_adapters/rspec'
require 'addressable/uri'
require 'open-uri'

class EgMapping
  def initialize(method,url,&block)
    @method = method
    @url    = Addressable::URI.heuristic_parse(url)
    @block  = block
  end

  def match?(request)
    (request.host == @url.host).tapp(:match?)
  end

  def response_for_request(request)
    response = HttpVanilli::NetHttp::Response.new(*@block.call)

    nh_rsp = response.to_net_http
    request.block[nh_rsp] if request.block

    nh_rsp
  end
end

describe 'stubbing' do
  #include HttpVanilli::RSpec

  before do
    HttpVanilli.disallow_net_connect!
    HttpVanilli.override_net_http!
    @m = HttpVanilli.request_mapper = HttpVanilli::BasicMapper.new
    @m.mapping_class = EgMapping
  end

  describe "expectation" do
    it "expects" do
    end
  end

  describe "stubbing" do
    it "stubs" do
      @m.add_mapping(:get, "http://google.com") { [200, {'content-type' => 'text/smileys'}, ["wikid"]] }

      open("http://google.com").read.should == 'wikid'
    end
  end

  describe "pass through" do
    it "allows net connects" do
    end

    it "disallows net connects" do
    end
  end
end
