module V1
  class ResourcegroupsController < ApiController
    before_action :load_resource

    def index
      render json: @resource.groups
    end

    def load_resource
      @resource = Resource.find(params[:resource_id])
    end
  end
end
