require 'faye/websocket'
require 'eventmachine'
require 'byebug'
require 'gemmy'
require 'active_support/all'
require 'awesome_print'

class WsClient

  attr_accessor :channels

  def start
    EM.run do
      server_url = ENV["SERVER_WS_URL"] || 'ws://localhost:3000/'
      ws = Faye::WebSocket::Client.new server_url
      setup_subscriptions(ws)
      ws.on :message, &method(:message_handler)
    end
  end

  def setup_subscriptions(ws)
    return if channels.blank?
    ws.send({
      type: "subscribe",
      channels: channels
    }.to_json)
  end

  def message_handler(event)
    ap event.data
  end

end
