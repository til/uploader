require 'rspec'
require 'uploader'
require 'uploader/too_large_error'

describe Uploader::TooLargeError do
  let(:too_large_error) { described_class.new(content_length: 1234) }

  it 'has a message' do
    too_large_error.message.should match(/File size of 1234 bytes is too large/)
    too_large_error.message.should match(/allowed are #{Uploader::Upload::ALLOWED_SIZE}/)
  end
end
