module Api
  module V1
    class LeadResource < JSONAPI::Resource
      attributes :name

      paginator :paged
    end
  end
end