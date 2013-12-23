module Uploader
  class Protector

    def initialize(secret)
      self.secret = secret
    end

    def check(upload_id, token)
      unless token
        raise Goliath::Validation::ForbiddenError
          .new("Missing token. URL must contain ?token=... part.")
      end
      unless token_valid?(upload_id, token)
        raise Goliath::Validation::ForbiddenError
          .new("Invalid token. Does not match for upload_id: #{upload_id}")
      end
    end

    private

    attr_accessor :secret

    def token_valid?(upload_id, token)
      token.downcase == computed_token(upload_id, token)
    end

    def computed_token(upload_id, token)
      Digest::SHA1.hexdigest("#{upload_id}#{secret}")
    end
  end
end
