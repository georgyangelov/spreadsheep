require 'digest/sha1'

socket '/socket/sheet/:id', proc { "sheet/#{params[:id]}" } do |socket|
  sheet_id  = params[:id]
  channel_id = "sheet/#{sheet_id}"
  socket_id = Digest::SHA1.hexdigest("#{sheet_id},#{current_user.id},#{DateTime.now},#{Random.rand}")

  ensure_user_access_to Sheet.find(sheet_id)

  # Set socket id
  socket.state[:user] = current_user.as_json(only: [:id, :full_name, :email]).symbolize_keys
  socket.state[:socket_id] = socket_id

  socket.onopen do
    # Send new user notification to others
    new_user_message = {
      type: 'new_user',
      user: current_user.as_json(only: [:id, :full_name, :email]),
      socket_id: socket_id,
      selection: nil
    }

    broadcast channel_id, new_user_message.to_json, exclude: socket

    # Send notification for existing users
    sockets_for_channel(channel_id).each do |other_user_socket|
      next if other_user_socket == socket

      new_user_message = {
        type: 'new_user',
        user: other_user_socket.state[:user],
        socket_id: other_user_socket.state[:socket_id],
        selection: other_user_socket.state[:selection]
      }

      socket.send new_user_message.to_json
    end
  end

  socket.onmessage do |message|
    message = JSON.parse(message, symbolize_names: true)

    case message[:type]
    when 'cell_changes'
      broadcast channel_id, message.to_json, exclude: socket

      Cell.update_cells_for_sheet(sheet_id, message[:changes])
    when 'row_column_resize'
      broadcast channel_id, message.to_json, exclude: socket

      state = RowColumnState.find_or_create_by(
        sheet_id: sheet_id,
        index:    message[:index],
        type:     RowColumnState.types[message[:row_column_type]]
      )
      state.width = message[:width]
      state.save
    when 'selection_change'
      message[:user_id] = socket.state[:user][:id]
      message[:socket_id] = socket_id

      socket.state[:selection] = {start: message[:start], end: message[:end]}

      broadcast channel_id, message.to_json, exclude: socket
    end
  end

  socket.onclose do
    remove_user_message = {
      type: 'remove_user',
      user: current_user.as_json(only: [:id, :full_name, :email]),
      socket_id: socket_id
    }

    broadcast channel_id, remove_user_message.to_json, exclude: socket
  end
end
