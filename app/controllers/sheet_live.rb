require 'digest/sha1'

class SheetLive
  def initialize(sinatra_context, socket, current_user, sheet_id, channel_id)
    @sinatra_context = sinatra_context
    @socket = socket
    @sheet_id = sheet_id
    @channel_id = channel_id
    @socket_id = @socket.state[:socket_id]

    @socket.state[:user] = current_user.as_json(only: [:id, :full_name, :email]).symbolize_keys
  end

  def after_connect
    notify_of_existing_users
    notify_of_new_user
  end

  def message_received(message)
    message = JSON.parse(message, symbolize_names: true)

    public_send "handle_#{message[:type]}", message
  end

  def handle_cell_changes(message)
    broadcast message

    Cell.update_cells_for_sheet(@sheet_id, message[:changes])
  end

  def handle_row_column_resize(message)
    broadcast message

    state = RowColumnState.find_or_create_by(
      sheet_id: @sheet_id,
      index:    message[:index],
      type:     RowColumnState.types[message[:row_column_type]]
    )
    state.width = message[:width]
    state.save
  end

  def handle_selection_change(message)
    message[:user_id] = @socket.state[:user][:id]
    message[:socket_id] = @socket_id

    @socket.state[:selection] = {start: message[:start], end: message[:end]}

    broadcast message
  end

  def after_close
    broadcast type: 'remove_user',
              user: @socket.state[:user],
              socket_id: @socket_id
  end

  private

  def broadcast(message)
    @sinatra_context.broadcast @channel_id, message.to_json, exclude: @socket
  end

  def notify_of_existing_users
    @sinatra_context.sockets_for_channel(@channel_id).each do |other_user_socket|
      next if other_user_socket == @socket

      new_user_message = {
        type: 'new_user',
        user: other_user_socket.state[:user],
        socket_id: other_user_socket.state[:socket_id],
        selection: other_user_socket.state[:selection]
      }

      @socket.send new_user_message.to_json
    end
  end

  def notify_of_new_user
    broadcast type: 'new_user',
              user: @socket.state[:user],
              socket_id: @socket_id,
              selection: nil
  end
end

socket '/socket/sheet/:id', proc { "sheet/#{params[:id]}" } do |socket|
  sheet_id  = params[:id]
  channel_id = "sheet/#{sheet_id}"
  socket_id = Digest::SHA1.hexdigest("#{sheet_id},#{current_user.id},#{DateTime.now},#{Random.rand}")

  ensure_user_access_to Sheet.find(sheet_id)

  # Set socket id
  socket.state[:socket_id] = socket_id

  controller = SheetLive.new(self, socket, current_user, sheet_id, channel_id)

  socket.onopen    { controller.after_connect }
  socket.onmessage { |message| controller.message_received(message) }
  socket.onclose   { controller.after_close }
end
