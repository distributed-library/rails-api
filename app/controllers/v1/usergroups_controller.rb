module V1
  class UsergroupsController < ApiController
    def index
      render json: current_user.groups
    end

    def create
      current_user.groups << Group.find(params[:usergroup][:id])
      render json: current_user.save
    end

    def destroy
      current_user.group_ids.delete(Group.find(params[:id]).id)
      render json: current_user.save
    end

  end
end
