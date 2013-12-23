require 'rspec'
require 'uploader'
require 'uploader/route'

describe Uploader::Route do
  context 'root' do
    subject { Uploader::Route.new('PATH_INFO' => '/') }

    its(:type) { should == :root }
    it { should_not be_protected }
  end

  context 'status' do
    subject { Uploader::Route.new('PATH_INFO' => '/status') }
    its(:type) { should == :status }
    it { should_not be_protected }
  end

  context 'status/active' do
    subject { Uploader::Route.new('PATH_INFO' => '/status/active') }
    its(:type) { should == :status_active }
    it { should_not be_protected }
  end

  context 'upload' do
    subject { Uploader::Route.new('PATH_INFO' => '/1234') }
    its(:type) { should == :upload }
    its(:upload_id) { should == 1234 }
    it { should be_protected }
  end

  context 'progress json' do
    subject { Uploader::Route.new('PATH_INFO' => '/1234/progress.json') }
    its(:type) { should == :progress_json }
    its(:upload_id) { should == 1234 }
    it { should be_protected }
  end

  it 'does not recognize mixture of digits and chars' do
    Uploader::Route.new('PATH_INFO' => '/123foo')
      .type.should be_nil
  end

  it 'does not recognize 0' do
    Uploader::Route.new('PATH_INFO' => '/0')
      .type.should be_nil
  end

  it 'does not recognize unrecognizable URLs' do
    Uploader::Route.new('PATH_INFO' => '/foo')
      .type.should be_nil
  end
end
