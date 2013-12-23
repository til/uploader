# -*- coding: utf-8 -*-
require 'rspec'
require 'uploader'
require 'uploader/upload'
require 'uploader/target'

describe Uploader::Target do
  let(:target) { Uploader::Target.new(dir: dir, id: id) }
  let(:id) { 1234 }
  let(:dir) { Pathname.pwd.join('uploads-test') }

  describe 'write' do
    let(:file) { double }
    before { target.stub(file: file) }

    it 'writes to file' do
      file.should_receive(:write).with(data = double)
      target.write data
    end
  end

  describe 'writing to file' do
    before { dir.mkdir }
    after { FileUtils.rm_rf(dir) }

    context 'when finished was called' do
      it 'creates final file' do
        target.filename = 'foo.mp3'
        target.write 'datadatadata'
        target.finish

        dir.join('1234_01_foo.mp3').read.should == 'datadatadata'
      end
    end

    context 'when finish was not called' do
      it 'does not create final file' do
        target.filename = 'foo.mp3'
        target.write 'datadatadata'

        dir.join('1234_01_foo.mp3').should_not exist
      end
    end
  end

  describe 'path' do
    subject { target.path }
    let(:basename) { subject.basename.to_s }
    before { target.stub(id: '1234', number: '01', filename: 'foo.mp3') }

    it 'is in dir' do
      subject.parent.should == dir
    end

    it 'joins id, number and filename' do
      basename.should == '1234_01_foo.mp3'
    end
  end

  describe 'number' do
    subject { target.number }

    it 'is 01 by default' do
      subject.should == '01'
    end

    context 'when other numbers exist' do
      before do
        target.stub(dir: Pathname.new('/foo/bar'))
        Dir.should_receive(:glob)
          .with('/foo/bar/1234_*')
          .and_return(['1234_01_foo.mp3'])
      end

      it 'is next number' do
        subject.should == '02'
      end
    end
  end
end
