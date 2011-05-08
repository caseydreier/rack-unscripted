module Rack
  class Unscripted
    def initialize(app, warning_message = nil)
      self.warning_message = warning_message if warning_message
      @app = app
    end

    def call(env)
      @status, @headers, @response = @app.call(env)
      if valid_content_type?(@headers['Content-Type']) && valid_status?(@status)
        @response.each do |response_line|
          insert_js(response_line)   if response_line =~ head_regex
          insert_html(response_line) if response_line =~ body_regex
        end
      end
      [@status, @headers, @response]
    end

  private

    attr_writer :warning_message

    def insert_js(response_line)
      add_to_content_length(inline_code.length)
      response_line.sub!(head_regex, inline_code + '\1')
    end

    # Inserts HTML of javascript warning after the opening body tag.
    def insert_html(response_line)
      add_to_content_length(no_javascript_warning.length)
      response_line.sub!(body_regex, '\1'+ no_javascript_warning)
    end

    def no_javascript_warning
      "<div id='rack-unscripted-no-javascript-warning'>#{warning_message}</div>"
    end

    def inline_code
      <<-END
<script type="text/javascript">document.write('<style>#rack-unscripted-no-javascript-warning{display:none;}</style>');</script>
      END
    end

    # Regular Expression to find the opening body tag.
    def body_regex
      /(<\s*body[^>]*>)/i
    end

    # Regular expression to find the closing </head> tag in a document.
    def head_regex
      /(<\s*\/head[^>]*>)/i
    end

    # Appends the given number to the current content length in the headers.
    def add_to_content_length(number)
      if @headers['Content-Length']
        @headers['Content-Length'] = (@headers['Content-Length'].to_i + number.to_i).to_s
      end
    end

    # Returns +true+ if the content type is text/html. No need to add this message
    # to any other types of content.
    def valid_content_type?(content_type)
      content_type.respond_to?(:include?) && content_type.include?("text/html")
    end

    # Returns +true+ if the HTTP response code is such that we should append this warning message.
    def valid_status?(response_code)
      [200, 404].include? response_code.to_i
    end

    # Attribute reader for the warning message.  Sets a default value.
    def warning_message
      @warning_message ||= 'Warning, this site requires javascript to function properly. Please enable it.'
    end

  end
end