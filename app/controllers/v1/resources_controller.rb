module V1
  class ResourcesController < ApiController
    def index
      render json: Resource.all.to_json
    end
  end
end
