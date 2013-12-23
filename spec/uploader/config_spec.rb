require 'rspec'
require 'uploader'
require 'uploader/config'

describe Uploader::Config do

  describe 'setup' do
    before do
      Pathname.stub(pwd: root = double)
      root.stub(:join).with('config', 'secret.txt')
        .and_return(double(read: "thesecret\n"))
    end

    it 'reads contents of secret.txt file' do
      expect {
        described_class.setup
      }.to change {
        described_class.secret
      }.to('thesecret')
    end
  end
end
