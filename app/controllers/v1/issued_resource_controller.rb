module V1
  class IssuedResourceController < ApiController
    def index
      render json: current_user.groups.collect{|group| group.resources.not.where(aasm_state: 'available')}.flatten, root: 'issued_resource'
    end

    def create
      resource = Resource.find(params[:issuedResource][:id])
      resource.update_attribute(:issuer_id,current_user.id.to_s)
      render json: resource.issue!
    end

    def destroy
      resource = Resource.find(params[:id])
      render json: resource.cancel!
    end
  end
end
