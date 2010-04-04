#!/usr/bin/env ruby
require 'rubygems'
require 'em-websocket'

class EM::Channel
  def size
    @subs.size
  end
end

EventMachine.run {
  @channel = EM::Channel.new

  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|

    ws.onopen do
      sid = @channel.subscribe { |msg| ws.send msg }
      ws.send "#{sid}"

      @channel.push "<0>: { client_count: #{@channel.size} }"

      ws.onmessage do |msg|
        @channel.push "<#{sid}>: #{msg}"
      end

      ws.onclose do
        @channel.unsubscribe(sid)
        @channel.push "<#{sid}>: { remove: true }"
        @channel.push "<0>: { client_count: #{@channel.size} }"
      end

    end

  end
}
