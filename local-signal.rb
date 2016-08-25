#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.require :default

origin = 'http://localhost:3000' # client urls

$buffer = { server: [], client: [] }

set :port, 4000

before do
  response['Access-Control-Allow-Origin'] = origin
end

# These are queue names. You can put something into a queue, or fetch an entry
# from it.
options '/server' do
  response['Access-Control-Allow-Methods'] = 'PUT'
end

put '/server' do
  request.body.rewind
  $buffer[:server] << request.body.read

  status 200
end

get '/server' do
  $buffer[:server].shift
end

# ----------------------------------------------------------------------------
# Client queue:
options '/client' do
  response['Access-Control-Allow-Methods'] = 'PUT'
end

put '/client' do
  request.body.rewind
  $buffer[:client] << request.body.read

  status 200
end

get '/client' do
  $buffer[:client].shift
end

# ----------------------------------------------------------------------------

get '/' do
  (<<-EOS) % [$buffer[:server].count, $buffer[:client].count]
    Entries in queues:
    server: %s
    client: %s
  EOS
end
