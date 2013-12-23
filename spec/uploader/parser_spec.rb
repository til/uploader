require 'rspec'
require 'uploader'
require 'uploader/parser'

describe Uploader::Parser do
  subject { described_class.new(boundary, target) }
  let(:boundary) { '----------------------------569c16085866' }
  let(:target) { double('target', :filename= => nil) }
  let(:data) do
    "----------------------------569c16085866\r\n"\
    "Content-Disposition: form-data; name=\"file\"; filename=\"foo.txt\"\r\n"\
    "Content-Type: application/octet-stream\r\n"\
    "\r\n"\
    "this is foo line 1\n"\
    "this is foo line 2\n"\
    "\r\n"\
    "------------------------------569c16085866--\r\n"
  end

  it 'can parse full data at once' do
    parsed = ""
    subject.data(data) do |parsed_chunk|
      parsed << parsed_chunk
    end
    parsed.should == "this is foo line 1\nthis is foo line 2\n"
  end

  it 'can parse data in chunks' do
    parsed = ""
    [data[0..150], data[151..-1]].each do |chunk|
      subject.data(chunk) do |parsed_chunk|
        parsed << parsed_chunk
      end
    end
    parsed.should == "this is foo line 1\nthis is foo line 2\n"
  end

  it 'sends filename to target' do
    target.should_receive(:filename=).with('foo.txt')
    subject.data(data) { }
  end
end
