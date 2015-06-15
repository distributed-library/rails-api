module V1
  class ResourcesController < ApiController
    def index
      render json: Resource.all
    end

    def create
      render json: current_user.resources.create(resource_params)
    end
   
    private

    def resource_params
      params.require(:resource).permit(:name, :resource_type)
    end

  end
end
