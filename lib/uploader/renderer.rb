Encoding.default_external = 'UTF-8'

module Uploader
  class Renderer

    TEMPLATES = {
      root:   [],
      upload: [:upload_id, :token, :return_to],
      form:   [:upload_id, :token],
      status: [:started_at, :registry],
    }

    def initialize(dir: required)
      self.dir = dir
      define_template_methods
    end

    private

    attr_accessor :dir

    def define_template_methods
      TEMPLATES.each_pair do |key, attrs|
        attrs = attrs.map { |attr| "#{attr}: required" }
        template(key)
          .def_method(self.class, "#{key}(#{attrs.join(', ')})")
      end
    end

    def template(key)
      ERB.new(dir.join("#{key}.html.erb").read)
    end
  end
end
