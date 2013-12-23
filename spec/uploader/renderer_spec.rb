require 'rspec'
require 'nokogiri'
require 'uploader/renderer'

describe Uploader::Renderer do
  let(:renderer) { described_class.new(dir: Pathname('templates')) }
  let(:doc) { Nokogiri::HTML(view) }

  describe 'root' do
    let(:view) { renderer.root }

    it 'says hello' do
      doc.at('body').text.should match(/hello/i)
    end
  end

  describe 'upload' do
    let(:view) {
      renderer.upload(
        upload_id: 1234,
        token: 'thetoken',
        return_to: 'http://example.com') }

    it 'renders iframe with src URL' do
      doc.at('iframe')['src'].should == '/1234/form?token=thetoken'
    end

    it 'renders return-to div with link' do
      doc.at('#return-to a')['href'].should == 'http://example.com'
    end
  end

  describe 'form' do
    let(:view) {
      renderer.form(
        upload_id: 1234,
        token: 'thetoken') }

    it 'renders form with action' do
      doc.at('form')['action'].should == '/1234?token=thetoken'
    end
  end

  describe 'form' do
    let(:view) {
      renderer.form(
        upload_id: 1234,
        token: 'thetoken') }

    it 'renders form with action' do
      doc.at('form')['action'].should == '/1234?token=thetoken'
    end
  end

  describe 'status' do
    let(:view) {
      renderer.status(
        started_at: Time.new(2013, 1, 1, 14, 00),
        registry: double('registry', uploads: [])) }

    it 'renders started date' do
      doc.text.should include('2013-01-01')
    end
  end
end
