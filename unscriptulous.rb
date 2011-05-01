module Rack
  class Unscriptulous
    def initialize(app)
      @app = app
    end

    def call(env)
      @status, @headers, @response = @app.call(env)
      if @headers["Content-Type"].respond_to?(:include?) && @headers["Content-Type"].include?("text/html")
        @response.each do |response_line|
          insert_js(response_line)   if response_line =~ /<\/head>/
          insert_html(response_line) if response_line =~ body_regex
        end
      end
      [@status, @headers, @response]
    end

    def insert_js(response_line)
      add_to_content_length(inline_code.length)
      response_line.sub!(/<\/head>/, "#{inline_code}\n</head>")
    end

    def insert_html(response_line)
      add_to_content_length(no_javascript_warning.length)
      response_line.sub!(body_regex, '\1'+"\n#{no_javascript_warning}")
    end

    def no_javascript_warning
      "<div class='unscriptulous-no-javascript-warning'>Warning, this site requires javascript to function properly. Please enable it.</div>"
    end

    def inline_code
      <<-END
<script type="text/javascript">document.write('<style>.unscriptulous-no-javascript-warning { display:none }</style>');</script>
      END
    end

    def body_regex
      /(<\s*body[^>]*>)/
    end

    def add_to_content_length(number)
      if @headers['Content-Length']
        @headers['Content-Length'] = (@headers['Content-Length'].to_i + number.to_i).to_s
      end
    end
  end
end