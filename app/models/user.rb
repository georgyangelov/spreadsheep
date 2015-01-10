class User < ActiveRecord::Base
  validates_presence_of :full_name, :email
  validates_uniqueness_of :email

  validates :email, email: true

  has_secure_password
end
