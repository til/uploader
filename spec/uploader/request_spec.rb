require 'rspec'
require 'uploader'
require 'uploader/request'

describe Uploader::Request do
  subject { described_class.new(env) }

  context 'for GET request' do
    let(:env) {
      {
        'REQUEST_METHOD' => 'GET',
        'PATH_INFO' => '/the/path',
        'QUERY_STRING' => query_string,
      }
    }
    let(:query_string) { 'token=thetoken&return_to=%s' % CGI.escape('http://example.com/return') }

    its(:method) { should == :get }
    it { should_not be_post }
    its(:path_info) { should eq('/the/path') }
    its(:return_to) { should eq('http://example.com/return') }
    its(:path_info) { should eq('/the/path') }
    its(:query_string) { should eq(query_string) }
  end

  context 'for POST request' do
    let(:env) {
      {
        'REQUEST_METHOD' => 'POST',
        'CONTENT_LENGTH' => '1234',
        'CONTENT_TYPE' => 'multipart/form-data; boundary=theboundary',
        'QUERY_STRING' => query_string,
        'PATH_INFO' => '/the/path',
      }
    }
    let(:query_string) { 'token=thetoken&return_to=%s' % CGI.escape('http://example.com/return') }

    its(:method) { should == :post }
    it { should be_post }
    its(:content_length) { should eq(1234) }
    its(:boundary) { should eq('theboundary') }
    its(:token) { should eq('thetoken') }
    its(:path_info) { should eq('/the/path') }
    its(:query_string) { should eq(query_string) }
  end
end
