class ThinAdapter < Sinatra::Base
  def self.init
    set :server, 'thin'
    Faye::WebSocket.load_adapter('thin')
  end
end
