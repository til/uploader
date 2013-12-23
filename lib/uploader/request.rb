module Uploader
  class Request
    def initialize(env)
      self.env = env
    end

    def method
      env['REQUEST_METHOD'].downcase.to_sym
    end

    def post?
      method == :post
    end

    def content_length
      env['CONTENT_LENGTH'].to_i
    end

    def boundary
      env['CONTENT_TYPE'].split(';').last.split('=').last
    end

    def token
      params.fetch('token') { nil }
    end

    def path_info
      env['PATH_INFO']
    end

    def query_string
      env['QUERY_STRING'] || ''
    end

    def return_to
      params.fetch('return_to') { '/' }
    end

    private

    attr_accessor :env

    def params
      Rack::Utils.parse_nested_query(query_string)
    end
  end
end
