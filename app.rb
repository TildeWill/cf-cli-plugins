ENV['RACK_ENV'] ||= 'development'

require 'rubygems'
require 'sinatra/base'
require 'json'
require 'bundler'
require 'util/tar'

Bundler.require :default, ENV['RACK_ENV'].to_sym

$stdout.sync = true
$stderr.sync = true

class CliPluginsApp < Sinatra::Base
  include Util::Tar

  def get_plugins
    Dir.glob("#{plugins_dir}/cf-*").sort.map do |plugin|
      plugin[13..-1]
    end.reject do |plugin|
      plugin == "plugins"
    end.map do |plugin|
      {
        name: plugin,
        description: File.read(File.expand_path "plugins/cf-#{plugin}/description").strip
      }
    end
  end

  get '/search' do
    puts "term? #{request["term"]}"
    plugins = get_plugins
    if request["term"]
      plugins.select do |p|
        p[:name].match(/#{Regexp.escape(request["term"])}/)
      end.to_json
    else
      plugins.to_json
    end
  end

  get '/download/:name' do
    name = params[:name]
    plugin = get_plugins.find { |p| p[:name] == name }
    if plugin
      data = gzip(tar(File.join(plugins_dir, "cf-#{name}")))
      content_type 'application/octet-stream'
      attachment("cf-#{name}.tgz")
      data
    else
      pass
    end
  end

  run! if app_file == $0

  private

  def plugins_dir
    "./plugins"
  end
end
