Thread.abort_on_exception = true

class SharedServerDispatcher

  Subprocess = OpenStruct.new(
    input: [],
    output: [],
    command: "ruby ../client/client.rb",
    tick: 0.5
  )

  def self.input
    Subprocess.input
  end

  def self.output
    Subprocess.output
  end

  def self.init
    Thread.new do
      wrap_subprocess_io
    end
    Thread.new do
      forward_subprocess_output_to_websockets
    end
  end

  def self.wrap_subprocess_io
    PTY.spawn(Subprocess.command) do |stdout, stdin, pid|
      loop do
        write_input_to_subprocess(stdin)
        Subprocess.output += get_subprocess_output(stdout, stdin)
        sleep Subprocess.tick
      end
    end
  end

  def self.get_subprocess_output(stdout, stdin)
    output = []
    loop do
      rdout, *rest = IO.select [stdout], [], [], 0.1
      if rdout && rdout.member?(stdout)
        output << stdout.readline
      else
        break
      end
      sleep Subprocess.tick
    end
    output
  end

  def self.write_input_to_subprocess(stdin)
    input = Subprocess.input.shift
    stdin.write "#{input} \n" if input
  end

  def self.forward_subprocess_output_to_websockets
    loop do
      Subprocess.output.each_index do |idx|
        msg = Subprocess.output.shift
        Sockets.each { |socket| socket.send msg } if msg
      end
      sleep Subprocess.tick
    end
  end

end
