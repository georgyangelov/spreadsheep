class Cell < ActiveRecord::Base
  belongs_to :sheet

  validates_presence_of :row, :column, :content
end
