class Resource < ApplicationRecord
  belongs_to :resource_type, optional: true
  has_many :tag_assignments, as: :taggable
  has_many :tags, through: :tag_assignments
  validates :name, presence: true
  validates :resource_type, on: :create, presence: true
end
