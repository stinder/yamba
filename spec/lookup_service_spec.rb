require 'rspec'
require_relative '../lookup_service'

describe LookupService do

  it 'should upcase the input' do
    lookup_service = LookupService.new
    lookup_service.sanitise_input('M154hj').should eq 'M154HJ'
  end

  it 'should be able to deal with whitespace' do
    lookup_service = LookupService.new
    lookup_service.sanitise_input('M 15 4hj').should eq 'M154HJ'
  end
end