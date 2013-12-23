require 'rspec'
require 'uploader'
require 'uploader/config'
require 'uploader/protector'

describe Uploader::Protector do
  let(:protector) { described_class.new(secret) }
  let(:upload_id) { 1234 }
  let(:secret) { 'abcdef' }

  describe 'check' do
    subject { -> { protector.check(upload_id, token) } }

    context 'with valid token' do
      let(:token) { Digest::SHA1.hexdigest("#{upload_id}#{secret}") }

      it { should_not raise_exception }
    end

    context 'with valid but uppercase token' do
      let(:token) { Digest::SHA1.hexdigest("#{upload_id}#{secret}").upcase }

      it { should_not raise_exception }
    end

    context 'with invalid token' do
      let(:token) { 'invalid' }

      it { should raise_exception(Goliath::Validation::ForbiddenError, /invalid token/i) }
    end

    context 'without token' do
      let(:token) { nil }

      it { should raise_exception(Goliath::Validation::ForbiddenError, /missing token/i) }
    end
  end
end
