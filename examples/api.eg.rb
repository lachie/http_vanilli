require 'eg.helper'
require 'http_vanilli'

require 'open-uri'
require 'net/http'
require 'addressable/uri'
require 'sinatra/base'

# First off, enable `HttpVanilli`
HttpVanilli.override_net_http!

# I choose to disallow normal connections to the net;
# if I didn't do this, requests not matched by my responders would go out to the internet.
HttpVanilli.disallow_net_connect!

eg.setup do
  # Tell `HttpVanilli` to use a new instance of the `BasicMapper`.
  # You could also create your own mapper class and hand it in with `HttpVanilli.request_mapper`.
  #
  # You should keep in mind that there are a few pitfalls to implementing a request mapper, so sticking with 
  # `BasicMapper` is a good idea initially.
  @m = HttpVanilli.use_basic_mapper!(:eg => EgResponder)
end

eg.helpers do
  def Unmatched(&block)
    begin
      yield
      Assert(false)
    rescue Exemplor::Assert::Failure
      raise $!
    rescue
      Assert($!.message[/unmatched_request/])
    end
  end

  def post(url,form_vars={})
    Net::HTTP.post_form(URI.parse(url), form_vars)
  end
end

eg 'using the block matcher' do
  # The block responder sees each request as an `HttpVanilli::NetHttp::Request`.
  #
  # The block returns a rack-style response to respond.
  @m.add_block_responder do |req|
    # `req.uri` is an `Addressable::URI`
    query = req.uri.query_values

    if req.uri.host == 'google.com' && query['c'] == 'AU' && query['q'] == 'profits'
      [200,{},['returned search']]
    end
  end

  # `open` the following lines is using `open-uri` to fetch urls.
  Unmatched { open("http://bing.com/search.asp?q=profits") }

  Assert( open("http://google.com/?c=AU&q=profits").read == 'returned search' )
  Assert( open("https://google.com/?q=profits&c=AU").read == 'returned search' )
end

# `EgResponder` shows you how to implement your own responder. A responder must implement two methods:
# 
# * `match?(request)`
# * `rack_response(request)`
#
# Arguments to your responder's `initialize` are passed verbatim from `BasicMapper#add_responder`
class EgResponder
  include HttpVanilli::AbstractResponder

  def initialize(method,url,test_string)
    @method      = method
    @url         = Addressable::URI.heuristic_parse(url)
    @test_string = test_string
  end

  def match?(request)
    (request.host == @url.host)
  end

  def rack_response(request)
    [200, {'content-type' => 'text/smileys'}, [@test_string]]
  end
end

eg 'a custom responder' do
  @m.add_responder(:eg, :get, "http://bing.com"  , "gnarly")
  @m.add_responder(:eg, :get, "http://google.com", "wikid")

  Assert( open("http://google.com").read == 'wikid' )
  Assert( open("http://bing.com").read   == 'gnarly' )
  
  Assert( open("http://google.com").read == 'wikid' )
end

class RackSearchApp
  def initialize(app,host)
    @app  = app
    @host = host
  end

  def call(env)
    if env['SERVER_NAME'] == @host
      query = env['QUERY_STRING'][/q=(.*)/,1]
      [200, {'Content-Type' => 'text/plain'}, [query.reverse.upcase]]
    else
      @app.call(env)
    end
  end
end

eg 'a rack responder' do
  @m.add_rack_responder(RackSearchApp,'google.com')

  Assert( open('http://google.com/zhang/alang?q=ruby').read == 'YBUR' )
  Assert( open('https://google.com/?q=python').read == 'NOHTYP' )
  Unmatched { open('http://bing.com/?q=ruby') }
end

class SinatraSearch < Sinatra::Base
  get "/zhang/alang" do
    params[:q].reverse.upcase
  end
  post "/" do
    params[:q].upcase
  end
end

eg 'a sinatra rack responder' do
  @m.add_rack_responder(SinatraSearch)

  Assert( open('http://google.com/zhang/alang?q=ruby').read == 'YBUR'   )
  Assert( post('https://google.com/', 'q' => 'python').body == 'PYTHON' )
  Unmatched { open('http://google.com/nomatch/?q=ruby') }
end
