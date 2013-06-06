require 'rspec'
require_relative '../recent_stop_service'

describe 'RecentStopService' do

  it 'should get recent stops from cookies' do
    request = stub(:cookies => {'yamba' => 'a;b'})
    RecentStopService.new.get_stop_ids_from_cookie(request).should eq ['a', 'b']
  end

  it 'should return an empty list if no cookie present' do
    request = stub(:cookies => {})
    bus_stop = mock('bus_stop').should_not_receive(:where)
    RecentStopService.new.get_recent_stops(request, bus_stop).should eq []
  end

  it 'should get the recent bus stops from db' do
    request = stub(:cookies => {'yamba' => 'a;b'})
    bus_stop = mock('bus_stop')
    bus_stop.should_receive(:where).with("stop_id='a' OR stop_id='b'")
    RecentStopService.new.get_recent_stops(request, bus_stop)
  end

  it 'should remove the bus stop from cookie' do
    request = stub(:cookies => {'yamba' => 'a;b;c'})
    cookie_hash = RecentStopService.new.create_cookie_without_bus_stop(request,'b')
    cookie_hash[:value].should eq 'a;c'
  end

  it 'should create a new cookie with the additional bus stop' do
    request = stub(:cookies => {'yamba' => 'a;b'})
    cookie_hash = RecentStopService.new.create_cookie_with_additional_bus_stop(request,'c')
    cookie_hash[:value].should eq 'a;b;c'
  end

  it 'should not add the same id twice' do
    request = stub(:cookies => {'yamba' => 'a;b'})
    cookie_hash = RecentStopService.new.create_cookie_with_additional_bus_stop(request,'b')
    cookie_hash[:value].should eq 'a;b'
  end
end