require 'faye/websocket'
require 'eventmachine'

def start_tick_loop
  EM.tick_loop do
    Ws.send gets.chomp
  end.on_stop { EM.stop }
end

EM.run {

  Ws = Faye::WebSocket::Client.new('ws://localhost:3000/')

  Ws.on :message do |event|
    puts event.data
  end

  Ws.on :open do |event|
    start_tick_loop
  end

}

