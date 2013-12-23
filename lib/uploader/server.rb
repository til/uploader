require 'json'

class Uploader::FormatErrors
  include Goliath::Rack::AsyncMiddleware

  def initialize(app)
    @app = app
  end

  def post_process(env, status, headers, body)
    if Hash === body && body.fetch(:error, false)
      headers['Content-type'] = 'text/plain'
      body = body.fetch(:error).to_s + "\n"
    end
    [status, headers, body]
  end
end

module Uploader
  class Server < Goliath::API
    use FormatErrors
    use Rack::Static, urls: ['/assets']

    def initialize(opts = {})
      Config.setup
      self.root = Pathname($0).realpath.parent.parent
      self.started_at = Time.now
      self.registry = Registry.new
      self.protector = Protector.new(Config.secret)
      self.renderer = Renderer.new(dir: root.join('templates'))
      super(opts)
    end

    def on_headers(env, headers)
      route = Route.new(env)
      request = Request.new(env)
      log_request

      if request.post?
        upload = env['upload'] = Upload.new(
          id: route.upload_id,
          boundary: request.boundary,
          content_length: request.content_length)

        registry.put(upload)
        upload.check_content_length!
      end
    end

    def on_body(env, chunk)
      if Request.new(env).post?
        env['upload'].data(chunk)
      end
    end

    def on_close(env)
      if env['upload']
        env['upload'].close
      end
    end

    def response(env)
      route = Route.new(env)
      request = Request.new(env)

      protector.check(route.upload_id, request.token) if route.protected?

      case [request.method, route.type]
      when [:get, :root]
        [200, {'Content-Type' => 'text/html'}, renderer.root]
      when [:get, :status]
        [200, {'Content-Type' => 'text/html'}, renderer.status(started_at: started_at, registry: registry)]
      when [:get, :status_active]
        [200, {'Content-Type' => 'text/plain'}, registry.active_upload_count]
      when [:get, :upload]
        [200, {'Content-Type' => 'text/html'}, renderer.upload(
            upload_id: route.upload_id, token: request.token, return_to: request.return_to)]
      when [:get, :form]
        [200, {'Content-Type' => 'text/html'}, renderer.form(upload_id: route.upload_id, token: request.token)]
      when [:get, :progress_json]
        [200, {'Content-Type' => 'application/json'}, progress(route.upload_id)]
      when [:post, :upload]
        [200, {'Content-Type' => 'text/plain'}, 'Done.']
      else
        [404, {'Content-Type' => 'text/plain'}, 'Not found.']
      end
    end

    private

    attr_accessor :started_at, :registry, :protector, :renderer, :root

    def progress(upload_id)
      upload = registry.fetch(upload_id)

      {
        inProgress: upload.in_progress?,
        percentage: upload.percentage,
        message: upload.message,
      }.to_json
    end

    def log_request
      request = Request.new(env)
      env.logger.info [
        "#{request.method} #{request.path_info}",
        request.query_string
      ].reject(&:empty?).join('?')
    end
  end
end
