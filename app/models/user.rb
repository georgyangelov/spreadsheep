class User < ActiveRecord::Base
  validates_presence_of :full_name, :email
  validates_uniqueness_of :email

  validates :email, email: true

  has_secure_password

  has_and_belongs_to_many :directories

  def root_directory
    Directory.find_or_create_by! user: self, parent: nil, name: '$root'
  end
end
