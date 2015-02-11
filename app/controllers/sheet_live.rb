socket '/socket/sheet/:id', proc { "sheet/#{params[:id]}" } do |socket|
  sheet_id = params[:id]

  ensure_user_access_to Sheet.find(sheet_id)

  socket.onmessage do |message|
    message = JSON.parse(message, symbolize_names: true)

    case message[:type]
    when 'change' then Cell.update_cells_for_sheet(sheet_id, message[:changes])
    end
  end
end
