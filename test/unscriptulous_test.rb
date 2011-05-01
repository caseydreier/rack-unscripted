require 'rubygems'
require 'rack/test'
require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + '/../unscriptulous')

class UnscriptulousTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    other_app =  Proc.new do |env|
      [
        200,
        {'Content-Type' =>  'text/html', 'Content-Length' => '66'},
        Rack::Response.new(["<html><head></head><body><p>The Bucket of Truth</p></body></html>"])
      ]
    end
    Rack::Unscriptulous.new(other_app)
  end

  def test_inline_js_added
    get '/'
    assert_match /unscriptulous/i, last_response.body
  end

end