module Uploader
  class UnsupportedExtensionError < Goliath::Validation::UnsupportedMediaTypeError
    def initialize(extension: extension)
      super("Unknown file type .#{extension} - allowed are: #{Upload::ALLOWED_EXTENSIONS.join(', ')}.")
    end
  end
end
