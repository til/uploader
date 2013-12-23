require 'rspec'
require 'uploader'
require 'uploader/unsupported_extension_error'
require 'uploader/too_large_error'
require 'uploader/length_required_error'
require 'uploader/upload'

describe Uploader::Upload do
  subject { Uploader::Upload.new(
      id: id,
      boundary: boundary,
      content_length: content_length) }
  let(:id) { 1234000 }
  let(:boundary) { '--foo--bar--' }
  let(:content_length) { 5000 }

  describe 'dir' do

    it 'is uploads when environment is not test' do
      Goliath.stub(env: :development)
      subject.stub(root: root = double)
      root.should_receive(:join).with('uploads')
      subject.dir
    end

    it 'is uploads-test when environment is test' do
      Goliath.stub(env: :test)
      subject.stub(root: root = double)
      root.should_receive(:join).with('uploads-test')
      subject.dir
    end
  end

  describe 'target' do

    it 'instantiates new target with required attributes' do
      Uploader::Target.should_receive(:new).with(
        dir: subject.dir,
        id: subject.id
      ).and_return(target = double)

      subject.target.should == target
    end
  end

  describe 'data' do
    before { subject.stub(parser: parser, target: target) }
    let(:parser) { double(data: nil) }
    let(:chunk) { 'a' * 100 }
    let(:parsed) { double }
    let(:target) { double }

    it 'increases uploaded_size by chunk size' do
      expect {
        subject.data(chunk)

      }.to change {
        subject.uploaded_size

      }.by(100)
    end

    it 'sends data to parser, and parsed data to target' do
      parser.should_receive(:data).with(chunk).and_yield(parsed)
      target.should_receive(:write).with(parsed)

      subject.data(chunk)
    end
  end

  describe 'percentage' do

    it 'is 0 at start' do
      subject.percentage.should == 0
    end

    it 'is percentage of uploaded_size' do
      subject.uploaded_size = 1000
      subject.percentage.should == 0.2
    end
  end

  describe 'check_content_length!' do

    context 'when within acceptable range' do
      let(:content_length) { Uploader::Upload::ALLOWED_SIZE }

      it 'does not raise error' do
        expect {
          subject.check_content_length!
        }.to_not raise_error
      end
    end

    context 'when too large' do
      let(:content_length) { Uploader::Upload::ALLOWED_SIZE + 1 }

      it 'raises error' do
        expect {
          subject.check_content_length!
        }.to raise_error(Uploader::TooLargeError)

        subject.should be_aborted
        subject.message.should match(/File size .* too large/)
      end
    end

    context 'when zero' do
      let(:content_length) { 0 }

      it 'raises error' do
        expect {
          subject.check_content_length!
        }.to raise_error(Uploader::LengthRequiredError)
      end
    end
  end

  describe 'filename=' do
    it 'removes spaces' do
      subject.filename = '  Foo    Bar.mp3  '
      subject.filename.should == 'Foo_Bar.mp3'
    end

    it 'downcases extension' do
      subject.filename = 'Foo.MP3'
      subject.filename.should == 'Foo.mp3'
    end

    it 'does not raise on valid extensions' do
      expect {
        subject.filename = 'foo.mp3'
      }.to_not raise_error
    end

    it 'does not raise on valid upcased extensions' do
      expect {
        subject.filename = 'foo.MP3'
      }.to_not raise_error
    end

    it 'raises error and sets status on invalid extensions' do
      expect {
        subject.filename = 'foo.pdf'
      }.to raise_error(Uploader::UnsupportedExtensionError)

      subject.should be_aborted
      subject.message.should match(/Unknown file type/)
    end
  end
end
