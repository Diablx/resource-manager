class Lead < ApplicationRecord
  has_many :tag_assignments, as: :taggable
  has_many :tags, through: :tag_assignments
end
