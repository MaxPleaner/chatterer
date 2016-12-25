class Websocket
  def initialize(req)
    @req = req
    @socket = Faye::WebSocket.new(req.env)
    @stack = {}
  end
  def onopen &blk
    @stack[:onopen] = blk
  end
  def onclose &blk
    @stack[:onclose] = blk
  end
  def onmessage &blk
    @stack[:onmessage] = blk
  end
  def ready
    @socket.on(:open) { @stack[:onopen].call @req, @socket }
    @socket.on(:close) { @stack[:onclose].call @req, @socket }
    @socket.on(:message) { |msg| @stack[:onmessage].call @req, @socket, msg }
    @socket.rack_response
  end
end
