ENV['RACK_ENV'] ||= 'development'

require 'rubygems'
require 'sinatra/base'
require 'json'
require 'bundler'

Bundler.require :default, ENV['RACK_ENV'].to_sym

$stdout.sync = true
$stderr.sync = true

class CliPluginsApp < Sinatra::Base
  def get_plugins
    Dir.glob("../cf-*").map do |plugin|
      {
        name: plugin[6..-1],
        description: "A mighty fine plugin"
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
      send_file File.join('..', "cf-#{name}")
    else
      pass
    end
  end

  run! if app_file == $0
end
