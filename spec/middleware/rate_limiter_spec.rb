# spec/middleware/rate_limiter_spec.rb
require 'rails_helper'

RSpec.describe Middleware::RateLimiter do
  let(:localhost) { "127.0.0.1" }
  let(:app) { proc{[200,{},['OK']]} }
  let(:subject) { Middleware::RateLimiter.new(app) }
  let(:request) { Rack::MockRequest.new(subject) }

  RATE_LIMIT.times do |n|
    describe "#call" do
      it "should return OK response" do
        response = request.get("/home.json", "REMOTE_ADDR" => "IP" )
        expect(response).to be_successful
      end
    end
  end
  describe "#call" do
    it "should return too many requests response after limit" do
      response = request.get("/home.json", "REMOTE_ADDR" => "IP" )
      expect(response.status).to eq 429
      expect(response.body).to include "Rate limit exceeded. Try again in"
    end
  end

  describe "#client_ip" do
    context "if IP parameter is not sent in the first call" do
      it "should return nil" do
        expect(subject.send :client_ip).to be_nil
      end
    end
    context "if ip parameter is sent in the first call" do
      it "should return back the parameter" do
        expect(subject.send :client_ip, localhost).to eq localhost
      end
    end
  end

  describe "#request_count" do
    before do
      subject.stub(:client_ip).and_return(localhost)
    end
    context "if there is no record in Redis with key localhost" do
      it "should return nil" do
        expect(subject.send :request_count).to be_nil
      end
    end
    context "if there is a record in Redis with key localhost" do
      it "should return the value" do
        REDIS.set(localhost, 0)
        expect(subject.send :request_count).to eq 0
      end
    end
  end

  describe "#initialize_request_count" do
    before do
      subject.stub(:client_ip).and_return(localhost)
    end
    it "should initialize a key in Redis" do
      expect(REDIS).to receive(:set).with(localhost, 0)
      subject.send :initialize_request_count
    end
  end

  describe "#increment_request_count" do
    before do
      subject.stub(:client_ip).and_return(localhost)
    end
    context "if there is no record in Redis with key localhost" do
      it "should return 1" do
        expect(subject.send :increment_request_count).to eq 1
      end
    end
    context "if there is a record in Redis with key localhost" do
      it "should increment the value in Redis" do
        REDIS.set(localhost, 1)
        expect(REDIS).to receive(:incr).with(localhost)
        subject.send :increment_request_count
      end
    end
  end

  describe "#time_to_reset_counter" do
    before do
      subject.stub(:client_ip).and_return(localhost)
    end
    it "should call Redis ttl method" do
      expect(REDIS).to receive(:ttl).with(localhost)
      subject.send :time_to_reset_counter
    end
  end
end
