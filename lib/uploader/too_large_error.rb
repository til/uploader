module Uploader
  class TooLargeError < Goliath::Validation::RequestEntityTooLargeError
    def initialize(content_length: content_length)
      super("File size of #{content_length} bytes is too large, allowed are #{Upload::ALLOWED_SIZE} bytes.")
    end
  end
end
