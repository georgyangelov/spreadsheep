class Sheet < ActiveRecord::Base
  belongs_to :directory, touch: true
  belongs_to :user

  validates_presence_of :name

  has_many :cells
  has_many :row_column_states, dependent: :destroy

  after_create :create_empty_cells
  before_destroy :delete_cells

  def has_access?(user)
    self.user == user or directory.has_access? user
  end

  def row_sizes
    row_column_sizes(:row)
  end

  def column_sizes
    row_column_sizes(:column)
  end

  private

  def create_empty_cells
    # TODO: You know what there is to do :)
    Cell.create_all_empty_cells(id, 37, 100)
  end

  def delete_cells
    Cell.delete_all(['sheet_id = ?', id])
  end

  def row_column_sizes(type)
    states = row_column_states.where(type: RowColumnState.types[type])

    return [] if states.empty?

    max_index = states.map(&:index).max
    states = states.map { |state| [state.index, state.width] }.to_h

    0.upto(max_index).map { |index| states[index] }
  end
end
