class User < ActiveRecord::Base
  validates_presence_of :full_name, :email
  validates_uniqueness_of :email

  validates :email, email: true

  has_secure_password

  has_many :user_shares

  has_many :shared_directories,
           class_name: :Directory,
           through: :user_shares,
           source: :directory

  def root_directory
    Directory.find_or_create_by! creator: self, parent: nil, name: '$root'
  end
end
