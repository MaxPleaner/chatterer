require 'faye/websocket'
require 'eventmachine'
require 'byebug'
require 'gemmy'

EM.run do

  EM.tick_loop do
    Thread.new do
      inp = gets.chomp
      Ws.send inp
    end
  end.on_stop { EM.stop }

  ServerWebsocketUrl = ENV["SERVER_WS_URL"] || 'ws://localhost:3000/'

  Ws = Faye::WebSocket::Client.new ServerWebsocketUrl

  Ws.on :message do |event|
    puts "cli client received: #{event.data}"
  end

end

