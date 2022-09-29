module Api
  module V1
    class ResourceTypeResource < JSONAPI::Resource
      attributes :name
    end
  end
end