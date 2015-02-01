class UserShare < ActiveRecord::Base
  belongs_to :directory, inverse_of: :user_shares
  belongs_to :user, inverse_of: :user_shares
end
