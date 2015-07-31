module V1
  class ResourcesController < ApiController
    before_action :load_resource, only: [:show, :update, :destroy]
    before_action :search_params, only: [ :search ]

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

    # Search book details by isbn number or book title
    # params
    # params[:isbn]#String
    # params[:title]#String
    def search
      book = Book.new(params)
      render json: book.search
    end

    private

    def search_params
      render json: { message: "Please provide isbn number or title for book" } if invalid_search_params?
    end

    def invalid_search_params?
      params[:isbn].blank? && params[:title].blank?
    end

    def load_resource
      @resource = Resource.find(params[:id])
    end

    def resource_params
      params.require(:resource).permit(:name, :resource_type, :aasm_state, :isbn_number, group_ids: [])
    end

  end
end
