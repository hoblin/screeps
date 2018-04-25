# frozen_string_literal: true

require 'digest'
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
    response['modules'].each_pair do |identifier, body|
      FileUtils.mkdir_p File.join('js', branch)
      file_name = File.join('js', branch, identifier + '.js')
      update_local_file_if_needed(file_name, body)
    end
  end

  def upload
    ap client.upload
  end

  private

  def update_local_file_if_needed(file_name, content)
    existing_file_data = File.read(file_name)
    save_file(file_name, content) unless Digest::MD5.hexdigest(existing_file_data) == Digest::MD5.hexdigest(content)
    # TODO: Add js2coffee compilling
  end

  def save_file(file_name, content)
    File.open(file_name, 'w') do |f|
      f << content
    end
  end
end
