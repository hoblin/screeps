# frozen_string_literal: true

require 'digest'
require 'logger'
require 'awesome_print'
require_relative 'client.rb'

class Screeps
  attr_accessor :current_modification_type, :client

  def initialize(credentials)
    @logger = ::Logger.new(STDOUT)
    self.client = Client.new(credentials)
  end

  def sync(action, files)
    log 'Syncing'
    self.current_modification_type = action
    affected_dirs = files.map do |file_name|
      File.dirname(file_name).split('/')&.first
    end.flatten.uniq
    upload if affected_dirs.include?('js')
    compile if affected_dirs.include?('coffee')
  end

  def download
    log 'Downloading game code from server'
    response = client.download
    branch = response['branch']
    response['modules'].each_pair do |identifier, body|
      FileUtils.mkdir_p File.join('js', branch)
      file_name = File.join('js', branch, identifier + '.js')
      update_local_file_if_needed(file_name, body)
    end
  end

  def upload
    log 'Uploading game code to server'
    data = {
      branch: 'default',
      modules: collect_data_to_upload
    }
    result = client.upload(data)
    log_response(result)
  end

  def compile
    # TODO: Implement CoffeeScript sources compilation
  end

  def log(*args)
    @logger.ap(*args)
  end

  private

  def log_response(result)
    response = JSON.parse(result.body)
    if response['ok'] == 1
      log '  success'
    else
      log "  Error: #{response['error']}"
    end
  end

  def collect_data_to_upload
    Dir.glob('js/**/*.js').inject({}) do |memo, file_name|
      memo[File.basename(file_name).split('.')[0]] = File.read(file_name)
      memo
    end
  end

  def update_local_file_if_needed(file_name, content)
    existing_file_data = File.exist?(file_name) ? File.read(file_name) : ''
    save_file(file_name, content) unless Digest::MD5.hexdigest(existing_file_data) == Digest::MD5.hexdigest(content)
    # TODO: Add js2coffee compilling
  end

  def save_file(file_name, content)
    File.open(file_name, 'w') do |f|
      f << content
    end
  end
end
