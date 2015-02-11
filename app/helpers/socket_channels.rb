class SocketChannels
  attr_reader :channels

  def initialize
    @channels = {}
  end

  def broadcast(channel, message)
    return unless has_channel? channel

    @channels[channel].each do |socket|
      socket.send message
    end
  end

  def has_channel?(channel)
    @channels.key? channel
  end

  def new_connection(request, channel)
    request.websocket do |socket|
      yield socket if block_given?

      socket.onopen do
        @channels[channel] = [] unless @channels.key? channel
        @channels[channel] << socket
      end

      socket.onclose do
        @channels[channel].delete socket
        @channels.delete channel if @channels[channel].empty?
      end
    end
  end
end

module Sinatra
  module SocketChannels
    @@socket_channels = ::SocketChannels.new

    def socket(path, channel=path, &block)
      get path do
        if channel.respond_to? :call
          channel_name = instance_eval(&channel)
        else
          channel_name = channel
        end

        @@socket_channels.new_connection(request, channel_name) do |socket|
          instance_exec(socket, &block) if block_given?
        end
      end
    end

    def broadcast(channel, message)
      @@socket_channels.broadcast channel, message
    end

    def has_channel?(channel)
      @@socket_channels.has_channel? channel
    end
  end

  register SocketChannels
  helpers  SocketChannels
end
