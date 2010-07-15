require 'eg.helper'
require 'http_vanilli'

require 'open-uri'
require 'addressable/uri'

HttpVanilli.disallow_net_connect!
HttpVanilli.override_net_http!

eg.setup do
  @m = HttpVanilli.basic_mapper!
end

eg 'a simple mapping' do
  @m.add_mapping(:get, "http://google.com") { [200, {'content-type' => 'text/smileys'}, ["wikid"]] }
  Assert( open("http://google.com").read == 'wikid' )
end
