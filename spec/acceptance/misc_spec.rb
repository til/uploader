require 'rspec'
require 'net/http'
require 'acceptance/acceptance_spec_helper'

describe 'Misc responses' do
  include AcceptanceSpecHelper

  it 'Request unkown URL' do
    response = Net::HTTP.get_response(URI('http://localhost:9001/unknown'))
    response.code.should == '404'
  end
end
