module Api
  module V1
    class TagResource < JSONAPI::Resource
      attributes :name, :tag_category_id, :tag_category

      has_one :tag_category
    end
  end
end