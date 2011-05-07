require 'rubygems'
require 'rack/test'
require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + '/../unscriptulous')

class UnscriptulousTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    @other_app ||= Proc.new do |env|
      [
        200,
        {'Content-Type' =>  'text/html', 'Content-Length' => test_page_html.length.to_s},
        Rack::Response.new(test_page_html)
      ]
    end
    Rack::Unscriptulous.new(@other_app)
  end

  def test_inline_js_added
    get '/'
    assert_match /unscriptulous/i, last_response.body
  end

  def test_content_length_is_increased
    get '/'
    expected = app.send(:inline_code).length + app.send(:no_javascript_warning).length + test_page_html.length
    assert_equal expected, last_response.headers['Content-Length'].to_i
  end

  def test_takes_no_action_on_non_html_content_type
    json = "{\"success\":\"success\"}"
    @other_app =  Proc.new do |env|
        [
          200,
          {'Content-Type' =>  'application/json', 'Content-Length' => json.length.to_s},
          Rack::Response.new(json)
        ]
      end
    get '/'
    assert_equal json.length, last_response.headers['Content-Length'].to_i
    assert_equal json, last_response.body
  end

  private

  def test_page_html
    '<html><head></head><body class="such-and-such"><p>The Bucket of Truth</p></body></html>'
  end

end