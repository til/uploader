require 'rspec'
require 'uploader'
require 'uploader/unsupported_extension_error'

describe Uploader::UnsupportedExtensionError do
  let(:error) { described_class.new(extension: 'doc') }

  it 'has a message' do
    error.message.should match(/Unknown file type .doc/)
  end
end
