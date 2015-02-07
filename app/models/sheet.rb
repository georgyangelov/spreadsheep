class Sheet < ActiveRecord::Base
  belongs_to :directory
  belongs_to :user

  validates_presence_of :name

  has_many :sheets

  def has_access?(user)
    self.user == user or directory.has_access? user
  end
end
