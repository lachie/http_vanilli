require 'spec_helper'
require 'http_vanilli/test_adapters/rspec'
require 'open-uri'

describe 'stubbing' do
  #include HttpVanilli::RSpec

  before do
    HttpVanilli.disallow_net_connect!
    HttpVanilli.override_net_http!
    @m = HttpVanilli.request_mapper = HttpVanilli::BasicMapper.new
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
