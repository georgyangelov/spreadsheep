class Cell < ActiveRecord::Base
  belongs_to :sheet, touch: true

  validates_presence_of :row, :column

  def as_json(options={})
    super(only: [:row, :column, :content, :background_color, :foreground_color])
  end

  class << self
    def create_all_empty_cells(sheet_id, rows, columns)
      Cell.transaction do
        rows.times.flat_map do |row|
          values = columns.times.map do |column|
            "(#{sheet_id}, #{row}, #{column})"
          end.join(',')

          Cell.connection.execute("insert into cells (sheet_id, row, column) values #{values}")
        end
      end
    end

    # Changes is [{row: <row>, column: <column>, content: <content>}, ...]
    def update_cells_for_sheet(sheet_id, changes)
      Cell.transaction do
        changes.each do |change|
          update = {
            content:          change[:content],
            background_color: change[:background_color],
            foreground_color: change[:foreground_color]
          }.delete_if { |_, value| value.nil? }

          next if update.empty?

          Cell.where(
            'sheet_id = ? and row = ? and column = ?', sheet_id, change[:row], change[:column]
          ).update_all(update)
        end
      end
    end
  end
end
