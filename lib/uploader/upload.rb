module Uploader
  class Upload
    ALLOWED_SIZE       = 250 * 1024 * 1024
    ALLOWED_EXTENSIONS = %w[ mp3 ogg m4a m3u wav flac aif aiff wma ]

    attr_accessor :id, :filename, :message, :boundary, :uploaded_size, :content_length

    def initialize(id: id, boundary: boundary, content_length: content_length)
      self.id = id.to_i
      self.boundary = boundary
      self.content_length = content_length

      self.uploaded_size = 0
      self.state = :in_progress
    end

    def dir
      @dir ||= root.join(Goliath.env == :test ? 'uploads-test' : 'uploads')
    end

    def parser
      @parser ||= Parser.new(boundary, self)
    end

    def target
      @target ||= Target.new(
        dir: dir,
        id: id)
    end

    def data(chunk)
      return unless in_progress?

      self.uploaded_size += chunk.size
      parser.data(chunk) do |parsed|
        target.write parsed
      end
      self.message = nil
    end

    def in_progress?
      state == :in_progress
    end

    def aborted?
      state == :aborted
    end

    def close
      return unless in_progress?

      if uploaded_size == content_length
        target.finish
        self.state = :finished
        self.message = SuccessMessage.new.to_s
      else
        target.abort
        self.state = :aborted
        self.message = "Aborted"
      end
    end

    def percentage
      uploaded_size.to_f / content_length
    end

    def message
      @message || "#{(percentage * 100).round}%"
    end

    def filename=(filename)
      return unless in_progress?

      not_allowed = '[^a-zA-Z0-9.]'
      @filename = filename
        .gsub(/^#{not_allowed}+/, '')
        .gsub(/#{not_allowed}+$/, '')
        .gsub(/#{not_allowed}+/, '_')
        .gsub(/\.(.+)$/) {|ext| ext.downcase}

      check_filetype!

      target.filename = @filename
    end

    def check_content_length!
      if content_length.zero?
        raise_error(LengthRequiredError.new)
      end
      if content_length > ALLOWED_SIZE
        raise_error(TooLargeError.new(content_length: content_length))
      end
    end

    private

    attr_accessor :state

    def root
      Pathname.new(File.dirname(__FILE__)).join('../..')
    end

    def check_filetype!
      if ! filetype_allowed?
        raise_error(UnsupportedExtensionError.new(extension: extension))
      end
    end

    def filetype_allowed?
      Upload::ALLOWED_EXTENSIONS.include?(extension)
    end

    def extension
      File.extname(filename)[1..-1]
    end

    def raise_error(error)
      self.state = :aborted
      self.message = error.message
      raise error
    end
  end
end
