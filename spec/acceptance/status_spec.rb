require 'rspec'
require 'net/http'
require 'acceptance/acceptance_spec_helper'

describe 'Status page' do
  include AcceptanceSpecHelper

  it 'View status page' do
    page = Net::HTTP.get_response(URI('http://localhost:9001/status')).body
    page.should include('Up since: ')
  end
end
