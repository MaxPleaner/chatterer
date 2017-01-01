require 'sinatra/base'
require 'faye/websocket'
require 'gemmy'
require 'byebug'
require 'colored'

require_relative './lib/loader.rb'

Loader.run

class Server < Sinatra::Base

  set :server, 'thin'

  Faye::WebSocket.load_adapter('thin')

  using Gemmy.patch("object/i/m")

  using Gemmy.patch("hash/i/to_open_struct")

  get '/' do
    Routes::Index.run(request_obj)
  end

  def request_obj
    if !defined?(request.renderers)
      _renderers = m(:renderers)
      request.define_singleton_method(:renderers) { _renderers.call }
    end
    request
  end

  def renderers
    {
      slim: m(:slim)
    }.to_ostruct
  end

end

Server.run! if __FILE__ == $0
