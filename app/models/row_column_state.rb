class RowColumnState < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  belongs_to :sheet, touch: true

  validates_presence_of :index, :type
  validates_numericality_of :index

  enum type: [:row, :column]
end
