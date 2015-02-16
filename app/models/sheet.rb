class Sheet < ActiveRecord::Base
  belongs_to :directory, touch: true
  belongs_to :user

  validates_presence_of :name

  has_many :cells
  has_many :row_column_states

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

  def row_column_sizes(type)
    states = row_column_states.where(type: RowColumnState.types[type])

    return [] if states.empty?

    max_index = states.map(&:index).max
    states = states.map { |state| [state.index, state.width] }.to_h

    0.upto(max_index).map { |index| states[index] }
  end
end
