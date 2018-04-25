# frozen_string_literal: true

require 'awesome_print'
require_relative 'client.rb'

class Screeps
  attr_accessor :client

  def initialize(credentials)
    self.client = Client.new(credentials)
  end

  def download
    response = client.download
    branch = response['branch']
    response['modules'].each_pair do |ident, body|
      FileUtils.mkdir_p File.join('js', branch)
      File.open(File.join('js', branch, ident + '.js'), 'w') do |f|
        f << body
      end
    end
  end

  def upload
    ap client.upload
  end
end
