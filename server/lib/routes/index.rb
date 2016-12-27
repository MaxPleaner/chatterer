class Routes::Index

  using Gemmy.patch "object/i/m"
  using Gemmy.patch "method/i/bind"

  def self.run(request)
    is_websocket = websocket_request? request
    m(is_websocket ? :websocket_request : :http_request).call request
  end

  def self.websocket_request?(request)
    Faye::WebSocket.websocket? request.env
  end

  def self.http_request request
    request.renderers.slim.call :index
  end

  def self.websocket_request request
    socket = Websocket.new request
    socket.onopen &m(:onopen)
    socket.onmessage &m(:onmessage)
    socket.onclose &m(:onclose)
    socket.ready
  end

  def self.onopen(request, ws)
    Sockets << ws
  end

  def self.onmessage(request, ws, msg)
    EM.next_tick do
      Sockets.each do |s|
        s.send({origin: "server", msg: msg.data}.to_json)
      end
    end
  end

  def self.onclose(request, ws)
    Sockets.delete(ws)
  end

end
