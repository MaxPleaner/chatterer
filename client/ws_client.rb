require 'faye/websocket'
require 'eventmachine'
require 'byebug'
require 'gemmy'
require 'active_support/all'
require 'awesome_print'

class WsClient

  attr_accessor :channels

  def start
    setup_message_logs
    EM.run do
      server_url = ENV["SERVER_WS_URL"] || 'ws://localhost:3000/'
      ws = Faye::WebSocket::Client.new server_url
      setup_subscriptions(ws)
      ws.on :message, &method(:message_handler)
    end
  end

  def setup_message_logs
    @log_folder = "message_logs"
    `mkdir -p #{@log_folder}`
  end

  def log_file_path(channel)
    "#{@log_folder}/#{normalize_channel_name(channel)}"
  end

  def normalize_channel_name(channel)
    channel.gsub /[^a-zA-Z0-9_-]/, ''
  end

  def log_msg(channel, msg)
    File.open(log_file_path(channel), 'a') { |f| f.write msg }
  end

  def setup_subscriptions(ws)
    @channels = channels
    return if channels.blank?
    ws.send({
      type: "subscribe",
      channels: channels
    }.to_json)
  end

  # def log_error(msg)
  #   `touch error.log`
  #   File.open("error.log", 'a') { |f| f.write msg }
  # end

  def message_handler(event)
    data = JSON.parse event.data
    case data['name']
    when "html"
      handle_html(data)
    end
  end

  def handle_html(data)
    plaintext_rendering = w3m_dump create_path data["data"]
    puts plaintext_rendering
    log_msg(data["channel"], plaintext_rendering)
  end

  def w3m_dump(path)
    `cat #{path} | w3m -dump -T text/html`
  end

  def create_path(html)
    Tempfile.new.tap { |f|
      f.write html
      f.close
    }.path
  end


end
