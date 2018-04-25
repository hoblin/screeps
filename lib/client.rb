# frozen_string_literal: true

require 'httparty'

class Client
  API_ENDPOINT = '/api/user/code'
  include HTTParty

  base_uri 'https://screeps.com'

  attr_accessor :token

  def initialize(credentials)
    self.token = credentials
    raise 'Credentials not provided' if token.nil?
  end

  def download
    JSON.parse self.class.get(API_ENDPOINT, query: { _token: token }).body
  end

  def upload(data)
    self.class.post(API_ENDPOINT, body: data.to_json, headers: { 'Content-Type' => 'application/json', 'X-Token' => token })
  end
end
