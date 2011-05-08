require 'rubygems'
require 'rack/test'
require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + '/../lib/rack/unscripted')

class Rack::UnscriptedTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    @other_app ||= other_app
    @custom_warning_message ||= nil
    Rack::Unscripted.new(@other_app, @custom_warning_message)
  end

  def test_inline_js_added
    get '/'
    assert last_response.body.include?(app.send(:inline_code) + '</head>')
  end

  def test_default_warning_message_added_to_response_body
    get '/'
    assert last_response.body.include?("<body class=\"such-and-such\">" + app.send(:no_javascript_warning))
  end

  def test_custom_message_added_to_response_body
    @custom_warning_message = "¡Se necissita activar JavaScript!"
    get '/'
    assert last_response.body.include?(@custom_warning_message)
  end

  def test_content_length_is_increased
    get '/'
    expected = app.send(:inline_code).length + app.send(:no_javascript_warning).length + test_page_html.length
    assert_equal expected, last_response.headers['Content-Length'].to_i
  end

  def test_takes_no_action_on_non_html_content_type
    json = "{\"success\":\"success\"}"
    @other_app = other_app(200, {'Content-Type' =>  'application/json', 'Content-Length' => json.length.to_s}, Rack::Response.new(json))
    get '/'
    assert_equal json.length, last_response.headers['Content-Length'].to_i
    assert_equal json, last_response.body
  end

  def test_takes_no_action_on_non_200_or_404_status_responses
    # Obviously, this isn't all possible responses, but you get the idea.
    [204, 302, 406, 500].each do |status|
      @other_app = other_app(status)
      get '/'
      assert_equal test_page_html.length, last_response.headers['Content-Length'].to_i
      assert_equal test_page_html, last_response.body
    end
  end

  private

  def other_app(status = 200, headers = nil, response = nil)
    headers  = {'Content-Type' =>  'text/html', 'Content-Length' => test_page_html.length.to_s} unless headers
    response =  Rack::Response.new(test_page_html) unless response
    Proc.new do |env|
      [status, headers, response]
    end
  end

  def test_page_html
    '<html><head></head><body class="such-and-such"><p>The Bucket of Truth</p></body></html>'
  end

end