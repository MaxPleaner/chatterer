Thread.abort_on_exception = true

class SharedServerDispatcher

  Subprocess = OpenStruct.new(
    input: [],
    output: [],
    path: "ruby ../client/client.rb"
  )

  def self.input
    Subprocess.input
  end

  def self.output
    Subprocess.output
  end

  def self.init

    Thread.new do
      Open3.popen3(Subprocess.path) do |stdin, stdout, stderr|
        Thread.new do
          loop do
            input = Subprocess.input.shift
            stdin.write input
            stdout.each_line { |line| Subprocess.output.push line }
            sleep 0.25
          end
        end
      end
    end

    Thread.new do

    end

  end

end
