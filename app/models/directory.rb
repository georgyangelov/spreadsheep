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
  before_save   :generate_slug

  default_scope { includes(:user_shares) }

  scope :root_shares, ->(user_id) do
    where(
      'creator_id != ? and directories.id in (select directory_id from user_shares where user_id = ?) and directories.parent_id not in (select directory_id from user_shares where user_id = ?)',
      user_id,
      user_id,
      user_id
    )
  end

  def root?
    parent_id.nil?
  end

  def shared?
    all_allowed_user_ids.size > 1
  end

  def parent_for_user(user)
    return if root?

    path_for_user = path_to_root_for_user(user)

    return user.root_directory if path_for_user.size == 1

    path_for_user[-2]
  end

  def has_direct_access?(user)
    creator_id == user.id or user_shares.any? { |share| share.user_id == user.id }
  end

  def has_access?(user)
    creator_id == user.id or all_allowed_user_ids.include? user.id
  end

  def all_allowed_user_ids
    path_to_root.flat_map(&:user_shares).map(&:user_id).uniq
  end

  def path(user)
    "/#{path_to_root_for_user(user).map(&:name).join('/')}"
  end

  private

  def path_to_root_for_user(user)
    path_to_root.drop_while { |directory| not directory.has_direct_access? user }
  end

  def path_to_root
    return @path_to_root if @path_to_root

    directory = self
    path = []

    until directory.root?
      path << directory
      directory = directory.parent
    end

    @path_to_root = path.reverse
  end

  def generate_slug
    self.slug = name.parameterize
  end
end
