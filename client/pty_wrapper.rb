require 'active_support/all'
require 'byebug'
require 'pty'

PTY.spawn("ruby client.rb") do |stdout, stdin,thread|
loop do
  rdin, rdout = IO.select([stdin], [stdout])
  if rdin && rdout.member?(stdout)
    byebug
    puts stdout.readline
  else
    break
  end
end
byebug
false
end
