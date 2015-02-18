class Cell < ActiveRecord::Base
  belongs_to :sheet, touch: true

  validates_presence_of :row, :column

  def as_json(options={})
    super(only: [:row, :column, :content, :background_color, :foreground_color])
  end

  class << self
    # Changes is [{row: <row>, column: <column>, content: <content>}, ...]
    def update_cells_for_sheet(sheet_id, changes)
      changes.each do |change|
        query = {
          sheet_id: sheet_id,
          row:      change[:row],
          column:   change[:column]
        }

        cell = Cell.find_by(query)

        if cell
          cell.content = change[:content] if change[:content]
          cell.background_color = change[:background_color] if change[:background_color]
          cell.foreground_color = change[:foreground_color] if change[:foreground_color]
          cell.save
        else
          Cell.create query.merge(
            content:          change[:content],
            background_color: change[:background_color],
            foreground_color: change[:foreground_color]
          )
        end
      end
    end
  end
end
