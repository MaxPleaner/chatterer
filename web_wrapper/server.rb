require 'ostruct'
require 'sinatra/base'
require 'faye/websocket'
require 'gemmy'
require 'byebug'
require 'open3'
require_relative './lib/recursive_require'
RecursiveRequire.init

class Server < Sinatra::Base

  include RequestObjectWrapper
  extend Routes

  ThinAdapter.init
  SharedServerDispatcher.init

end
