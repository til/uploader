require 'rspec'
require 'net/http'
require 'acceptance/acceptance_spec_helper'

describe 'Status page' do
  include AcceptanceSpecHelper

  specify 'View status page' do
    page = Net::HTTP.get_response(URI('http://localhost:9001/status')).body
    page.should include('Up since: ')
  end

  specify 'View count of active uploads' do
    page = Net::HTTP.get_response(URI('http://localhost:9001/status/active')).body
    page.should eq('0')
  end
end
