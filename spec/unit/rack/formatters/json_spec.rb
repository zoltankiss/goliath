require 'spec_helper'
require 'goliath/rack/formatters/json'

describe Goliath::Rack::Formatters::JSON do
  it 'accepts an app' do
    lambda { Goliath::Rack::Formatters::JSON.new('my app') }.should_not raise_error
  end

  describe 'with a formatter' do
    before(:each) do
      @app = double('app').as_null_object
      @js = Goliath::Rack::Formatters::JSON.new(@app)
    end

    it 'checks content type for application/json' do
      @js.json_response?({'Content-Type' => 'application/json'}).should be_truthy
    end

    it 'returns false for non-applicaton/json types' do
      @js.json_response?({'Content-Type' => 'application/xml'}).should be_falsey
    end

    it 'calls the app with the provided environment' do
      env_mock = double('env').as_null_object
      @app.should_receive(:call).with(env_mock).and_return([200, {}, {"a" => 1}])
      @js.call(env_mock)
    end

    it 'formats the body into json if content-type is json' do
      @app.should_receive(:call).and_return([200, {'Content-Type' => 'application/json'}, {:a => 1, :b => 2}])

      status, header, body = @js.call({})
      lambda { MultiJson.load(body.first)['a'].should == 1 }.should_not raise_error
    end

    it "doesn't format to json if the type is not application/json" do
      @app.should_receive(:call).and_return([200, {'Content-Type' => 'application/xml'}, {:a => 1, :b => 2}])

      MultiJson.should_not_receive(:dump)
      status, header, body = @js.call({})
      body[:a].should == 1
    end

    it 'returns the status and headers' do
      @app.should_receive(:call).and_return([200, {'Content-Type' => 'application/xml'}, {:a => 1, :b => 2}])

      MultiJson.should_not_receive(:dump)
      status, header, body = @js.call({})
      status.should == 200
      header.should == {'Content-Type' => 'application/xml'}
    end
  end
end

