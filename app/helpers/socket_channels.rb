class SocketChannels
  attr_reader :channels

  def initialize
    @channels = {}
  end

  def broadcast(channel, message, exclude: nil)
    return unless has_channel? channel

    sockets_for_channel(channel).each do |socket|
      next if exclude and socket == exclude

      socket.send message
    end
  end

  def has_channel?(channel)
    @channels.key? channel
  end

  def sockets_for_channel(channel)
    @channels[channel]
  end

  def new_connection(request, channel)
    request.websocket do |socket|
      @channels[channel] = [] unless @channels.key? channel

      socket_mux = CustomSocket.new(socket)

      yield socket_mux if block_given?

      socket_mux.onopen do
        @channels[channel] << socket_mux
      end

      socket_mux.onclose do
        @channels[channel].delete socket_mux
        @channels.delete channel if @channels[channel].empty?
      end
    end
  end
end

class CustomSocket
  EVENTS = [:onopen, :onclose, :onmessage, :onerror]

  attr_accessor :state

  def initialize(socket)
    @state = {}
    @socket = socket
    @handlers = EVENTS.map { |event| [event, []] }.to_h

    attach_handlers
  end

  EVENTS.each do |event|
    define_method event do |&block|
      @handlers[event] << block
    end
  end

  def method_missing(name, *args)
    @socket.public_send name, *args
  end

  def send(*args)
    @socket.send(*args)
  end

  private

  def call_handlers(event, *args)
    @handlers[event].each do |handler|
      handler.call(*args)
    end
  end

  def attach_handlers
    EVENTS.each do |event|
      @socket.public_send event do |*args|
        call_handlers(event, *args)
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

    def broadcast(*args)
      @@socket_channels.broadcast *args
    end

    def has_channel?(channel)
      @@socket_channels.has_channel? channel
    end

    def sockets_for_channel(*args)
      @@socket_channels.sockets_for_channel *args
    end
  end

  register SocketChannels
  helpers  SocketChannels
end
