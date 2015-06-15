module V1
  class UsergroupsController < ApiController
    def index
      render json: current_user.groups
    end
  end
end
