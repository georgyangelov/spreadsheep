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

  scope :root_shares, ->(user_id) do
    joins(:user_shares).where(
      'creator_id != ? and user_shares.user_id = ? and directories.parent_id not in (select directory_id from user_shares where user_id = ?)',
      user_id,
      user_id,
      user_id
    )
  end

  def root?
    !parent
  end

  def has_access?(user)
    creator == user or all_allowed_users.include? user
  end

  def all_allowed_users
    directory = self
    users = []

    until directory.nil?
      users |= directory.allowed_users

      directory = Directory.where(id: directory.parent_id).includes(:allowed_users).includes(parent: [:allowed_users]).first
    end

    users
  end

  def path
    "/#{path_to_root.map(&:name).join('/')}"
  end

  private

  def path_to_root
    directory = self
    path = []

    until directory.root?
      path << directory
      directory = directory.parent
    end

    path.reverse
  end

  def generate_slug
    self.slug = name.parameterize
  end
end
