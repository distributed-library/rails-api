module V1
  class ResourcesController < ApiController
    before_action :load_resource, only: [:show, :update, :destroy]

    def index
      render json: current_user.resources
    end

    def create
      render json: current_user.resources.create(resource_params)
    end

    def update
      render json: @resource.update_attributes(resource_params)
    end

    def show
      render json: @resource
    end

    def available
      render json: current_user.groups.collect{|group| group.resources.where(aasm_state: 'available')}.flatten, root: 'available_resource'
    end

    def destroy
      render json: @resource.destroy
    end

    private

    def load_resource
      @resource = Resource.find(params[:id])
    end

    def resource_params
      params.require(:resource).permit(:name, :resource_type, :aasm_state, :isbn_number, group_ids: [])
    end

  end
end
