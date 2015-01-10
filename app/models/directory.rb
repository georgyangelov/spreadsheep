class Directory < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :user
  belongs_to :parent, class_name: :Directory

  has_and_belongs_to_many :users

  before_create :generate_slug

  def subdirectories
    Directory.where parent: self
  end

  private

  def generate_slug
    self.slug = name.parameterize
  end
end
