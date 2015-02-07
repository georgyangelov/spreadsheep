class Directory < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :creator, foreign_key: :creator_id, class_name: :User
  belongs_to :parent, class_name: :Directory

  has_many :directories, foreign_key: :parent_id,
                         inverse_of: :parent,
                         dependent: :destroy

  has_many :user_shares

  has_many :allowed_users,
           class_name: :User,
           through: :user_shares,
           source: :user

  has_many :sheets

  before_create :generate_slug

  def root?
    !parent
  end

  def has_access?(user)
    creator == user or allowed_users.include? user
  end

  private

  def generate_slug
    self.slug = name.parameterize
  end
end
