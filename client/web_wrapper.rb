require 'sinatra'
require 'dotenv'
require 'slim'

Dotenv.load

class WebWrapper < Sinatra::Base

  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == 'foo' && password == 'bar'
  end

  get '/' do
    slim :index
  end

end
