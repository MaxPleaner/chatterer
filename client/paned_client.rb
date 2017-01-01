require 'byebug'
require 'faye/websocket'
require 'eventmachine'

module PanedClient

  def foobar
    main_pane = PanedRepl.panes.values.first
    ws_client("test", channels: ["test"])
    sleep 2.0
    send_to_channel("test", "html", <<-HTML)
      <ul><li>list<ul><li>list2</li></ul></li></ul>
    HTML
  end

  def ws_client(name, channels:)
    script = <<-RB
      require %{./ws_client.rb};
      client = WsClient.new;
      client.channels = %w{ #{channels.join(" ")} }
      client.start
    RB
    cmd name, rb(script)
  end

  def socket_client_tick_interval
    @socket_client_tick_interval ||= 0.5
  end

  def init_socket_client
    unless @socket_client_initialized
      Thread.new do
        EM.run do
          server_url = ENV["SERVER_WS_URL"] || 'ws://localhost:3000/'
          socket_client = Faye::WebSocket::Client.new server_url
          socket_client.on(:open) do |ws|
            EM.tick_loop do
              msg = message_queue.shift
              if msg
                EM.next_tick { socket_client.send msg }
              end
              sleep socket_client_tick_interval
            end
          end
        end
      end
    end
    @socket_client_initialized = true
  end

  def message_queue
    @message_queue ||= []
  end

  def build_action_msg(channel, name, data)
    { type: "action", channel: channel, name: name, data: data }.to_json
  end

  def send_to_channel(channel, name, data)
    init_socket_client
    message_queue.push build_action_msg(channel, name, data)
  end

  def exit_tmux
    panes.values.each &base.method(:kill_pane)
    `pkill tmux`
    exit
  end

  def panes
    @panes ||= {}
  end

  def base
    @base ||= PanedRepl.sessions.values.first
  end

  def pane_count
    @pane_count ||= 0
  end

  def cmd(cmd_name, cmd_string)
    unless panes[cmd_name]
      pane_count
      base.split_vertical
      base.even_vertical
      @pane_count = pane_count + 1
      pane_id = pane_count - 1
      panes[cmd_name] = pane_id
    end
    base.send_keys cmd_string, panes[cmd_name]
  end

  def rb(cmd_fragment)
    if ["\"", "\'"].any? &cmd_fragment.method(:include?)
      raise ArgumentError, "fragment cant have quotes"
    end
    <<-SH
    ruby -e '#{cmd_fragment}'
    SH
  end

end
