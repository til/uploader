module Uploader
  class Config
    @@secret = nil

    def self.setup
      filename = Goliath.env == :test ? 'secret-test.txt' : 'secret.txt'
      @@secret = Pathname.pwd.join('config', filename).read.chomp
    end

    def self.secret
      @@secret
    end
  end
end
