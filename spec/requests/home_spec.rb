# spec/requests/home_spec.rb
require 'rails_helper'

RSpec.describe "/", type: :request do
  describe "GET#index" do
    it "should return OK" do
      get '/home'
      expect(response.body).to eq 'OK'
    end
  end
end
