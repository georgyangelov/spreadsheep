class Cell < ActiveRecord::Base
  belongs_to :sheet, touch: true

  validates_presence_of :row, :column, :content

  def as_json(options={})
    super(only: [:row, :column, :content])
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

        if change[:content].nil? or change[:content] == ''
          Cell.destroy_all(query)
        else
          cell = Cell.find_by(query)

          if cell
            cell.content = change[:content]
            cell.save
          else
            Cell.create(query.merge(content: change[:content]))
          end
        end
      end
    end
  end
end
