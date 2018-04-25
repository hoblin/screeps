# frozen_string_literal: true

require 'digest'
require 'awesome_print'
require_relative 'client.rb'

class Screeps
  attr_accessor :current_modification_type, :client

  def initialize(credentials)
    self.client = Client.new(credentials)
  end

  def sync(action, files)
    self.current_modification_type = action
    affected_dirs = files.map { |file_name| File.dirname(file_name) }.uniq
    upload if affected_dirs.include?('js')
    compile if affected_dirs.include?('coffee')
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

  def compile
    # TODO: Implement CoffeeScript sources compilation
  end

  def log(*args)
    ap args
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
