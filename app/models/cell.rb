class Cell < ActiveRecord::Base
  belongs_to :sheet

  validates_presence_of :row, :column, :content

  class << self
    # Changes is [{row: <row>, column: <column>, value: <value>}, ...]
    def update_cells_for_sheet(sheet_id, changes)
      changes.each do |change|
        query = {
          sheet_id: sheet_id,
          row:      change[:row],
          column:   change[:column]
        }

        if change[:value].nil? or change[:value] == ''
          Cell.destroy_all(query)
        else
          cell = Cell.find_by(query)

          if cell
            cell.content = change[:value]
            cell.save
          else
            Cell.create(query.merge(content: change[:value]))
          end
        end
      end
    end
  end
end
