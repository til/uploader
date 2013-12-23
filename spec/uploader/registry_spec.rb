require 'rspec'
require 'uploader'
require 'uploader/registry'

describe Uploader::Registry do
  subject { described_class.new }

  describe 'put and fetch' do
    let(:upload_1) { double('upload', id: 1) }
    let(:upload_2) { double('upload', id: 2) }

    before do
      subject.put(upload_1)
      subject.put(upload_2)
    end

    it 'puts and fetches by id' do
      subject.fetch(upload_1.id).should == upload_1
    end

    it 'raises when id not found' do
      expect {
        subject.fetch(666)
      }.to raise_error(KeyError)
    end

    it 'has uploads' do
      subject.uploads.should == [upload_1, upload_2]
    end
  end

  describe 'active_upload_count' do

    it 'returns number of uploads that are in progress' do
      subject.put(double('upload', id: 1, in_progress?: false))
      subject.put(double('upload', id: 2, in_progress?: true))
      subject.put(double('upload', id: 3, in_progress?: true))

      subject.active_upload_count.should eq(2)
    end
  end
end
