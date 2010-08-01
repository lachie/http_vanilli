# `HttpVanilli` is a flexible web connection mocking library. It gives you lip-synced http connections with pluggable band members for testing.
#
# Its good for testing your webservice-interfacing code.
# 
# This file is an executable example of `HttpVanilli`'s basic API. Its written using [Myles Byrne's Exemplor][eg].
#
# To run it:
#     $ cd http_vanilli/examples
#     $ bundle install
#     $ ruby api.eg.rb
#
# [eg]: http://github.com/quackingduck/exemplor

require 'eg.helper'
require 'http_vanilli'

# First off, enable `HttpVanilli` by overriding the core request methods of `Net::HTTP`.
HttpVanilli.override_net_http!

# I choose to disallow normal connections to the net;
# if I didn't do this, requests not matched by my responders would go out to the internet.
HttpVanilli.disallow_net_connect!

eg.setup do
  # Tell `HttpVanilli` to use a new instance of the `HttpVanilli::BasicMapper`.
  # (You could also create your own mapper class and set it in with `HttpVanilli.request_mapper=`.)
  #
  # This is a good method to call in your test library's setup phase, as creating a new instance of the mapper
  # cleans out responders and other state stored in past instances.
  #
  # You should keep in mind that there are a few pitfalls to implementing a request mapper, so sticking with 
  # `HttpVanilli::BasicMapper` is a good idea initially.
  @m = HttpVanilli.use_basic_mapper!
end

#
eg.helpers do
  # An assertion. The block should raise if a request is unhandled.
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

  require 'net/http'

  def post(url,form_vars={})
    Net::HTTP.post_form(URI.parse(url), form_vars)
  end
end

## The block responder

require 'open-uri'
require 'addressable/uri'

# The block responder is simple & flexible, but doesn't do anything to make your life easier.

eg 'using the block matcher' do
  # The block is called for each request. 
  @m.add_block_responder do |req|
    # Requests are instances of `HttpVanilli::NetHttp::Request`.
    # `req.uri` is an `Addressable::URI`
    query = req.uri.query_values

    if req.uri.host == 'google.com' && query['c'] == 'AU' && query['q'] == 'profits'
      # The block returns a rack-style response to respond.
      #
      # If nil is returned, the request is considered to have been unhandled by the block.
      #
      # A corollary of this is that the block can be called multiple times for each request.
      [200,{},['returned search']]
    end
  end

  # Now to the requests!
  #
  # `open` here is `open-uri` enhanced, to fetch urls.
  Unmatched { open("http://bing.com/search.asp?q=profits") }

  # Notice how both of these assertions are true, even though the query keys are in different orders.
  Assert( open("http://google.com/?c=AU&q=profits" ).read == 'returned search' )
  Assert( open("https://google.com/?q=profits&c=AU").read == 'returned search' )
end



## Using a rack app as a responder.

# Heres a trivial rack app.
class RackSearchApp
  def initialize(app,host)
    @app  = app
    @host = host
  end

  def call(env)
    # I'm accessing `env` directly to demonstrate that you can, but of course you can use 
    # `Rack::Request` & `Rack::Response` if you like.
    if env['SERVER_NAME'] == @host
      query = env['QUERY_STRING'][/q=(.*)/,1]
      [200, {'Content-Type' => 'text/plain'}, [query.reverse.upcase]]
    else
      # You could return nil here, but then your app wouldn't quite be rack compliant.
      @app.call(env)
    end
  end
end

eg 'a rack responder' do
  # Arguments after the rack app's class become arguments to the app's initializer.
  @m.add_rack_responder(RackSearchApp,'google.com')

  Assert( open('http://google.com/zhang/alang?q=ruby').read == 'YBUR' )
  Assert( open('https://google.com/?q=python'        ).read == 'NOHTYP' )
  Unmatched { open('http://bing.com/?q=ruby') }
end

### Yep, its rack.
require 'sinatra/base'

# Which means you can use any rack-compliant framework. Obviously simpler is better for the task-at-hand (i.e. testing).
#
# Here's using Sinatra:
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


## A custom responder

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
  # We need to add the `EgResponder` to the mapper. Here's how to do it as we're creating the mapper.
  @m = HttpVanilli.use_basic_mapper!(:eg => EgResponder)

  # Now add instances of the `EgResponder` by referring to it by its key `:eg`.
  #
  # Arguments after `:eg` are passed to `EgResponder` as is.
  @m.add_responder(:eg, :get, "http://bing.com"  , "gnarly")
  @m.add_responder(:eg, :get, "http://google.com", "wikid")

  Assert( open("http://google.com").read == 'wikid'  )
  Assert( open("http://bing.com"  ).read == 'gnarly' )
  
  Assert( open("http://google.com").read == 'wikid'  )
end

