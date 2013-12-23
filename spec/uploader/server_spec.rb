require 'rspec'
require 'uploader'
require 'uploader/server'

describe Uploader::Server do
  describe 'initialize' do

    it 'sets up config, to survive a later change of working directory' do
      Uploader::Config.should_receive(:setup)
      described_class.new
    end
  end
end
