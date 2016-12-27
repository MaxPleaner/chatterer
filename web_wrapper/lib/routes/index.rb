class Routes::Index

  def self.run(request)
    is_websocket = Websocket.websocket? request
    method(
      is_websocket ? :websocket_request : :http_request
    ).call request
  end

  def self.http_request request
    request.renderers.slim.call :index
  end

  def self.websocket_request request
    socket = Websocket.new request
    socket.onopen &method(:onopen)
    socket.onmessage &method(:onmessage)
    socket.onclose &method(:onclose)
    socket.ready
  end

  def self.onopen(request, ws)
    Sockets << ws
  end

  def self.onmessage(request, ws, msg_json)
  end

  def self.onclose(request, ws)
    Sockets.delete(ws)
  end

end
