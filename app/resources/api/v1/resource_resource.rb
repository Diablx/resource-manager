module Api
  module V1
    class ResourceResource < JSONAPI::Resource
      attributes :name, :description, :url, :resource_type_id, :resource_type

      has_one :resource_type

      paginator :paged
      filter :resource_type_id
    end
  end
end