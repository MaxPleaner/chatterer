class Routes::Index

  using Gemmy.patch "object/i/m"
  using Gemmy.patch "method/i/bind"

  SubscriptionsBySocket = Hash.new { |hash, key| hash[key] = [] }
  SubscriptionsByChannel = Hash.new { |hash, key| hash[key] = [] }
  Auth = {}

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

  def self.subscriptions_by_socket
    Routes::Index::SubscriptionsBySocket
  end

  def self.subscriptions_by_channel
    Routes::Index::SubscriptionsByChannel
  end

  def self.auth
    Routes::Index::Auth
  end

  def self.onopen(request, ws)
  end

  def self.onmessage(request, ws, msg)
    msg_json = JSON.parse(msg.data) rescue nil
    case msg_json['type']
    when "subscribe"
      subscribe(ws, msg_json['channels'])
    when "action"
      action ws, *msg_json.values_at(*%w{channel name data})
    end
  end

  def self.subscribe(ws, channel_names)
    subscriptions_by_socket[ws].push *channel_names
    channel_names.each do |channel_name|
      subscriptions_by_channel[channel_name].push ws
    end
  end

  def self.action(sender_ws, channel, name, data)
    sockets = [ *subscriptions_by_channel[channel] ]
    sockets.each do |socket|
      unless subscriptions_by_socket[socket].include? channel
        subscriptions_by_channel[channel].delete socket
      end
    end
    sockets = [ *subscriptions_by_channel[channel] ]
    send_message sockets, build_action_response(channel, name, data)
  end

  def self.build_action_response(channel, name, data)
    { channel: channel, name: name, data: data }.to_json
  end

  def self.send_message(sockets, msg_json)
    EM.next_tick do
      sockets.each { |s| s.send msg_json }
    end
  end

  def self.onclose(request, ws)
    SubscriptionsBySocket.delete ws
  end

end
