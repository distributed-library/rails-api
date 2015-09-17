module V1
  class GroupsController < ApiController
    respond_to :json
    before_action :load_group, only: [:show, :destroy]

    def index
      render json: Group.all
    end

    def create
      param = group_params.merge!({owner_id: current_user.id.to_s})
      render json: current_user.groups.create(param)
    end

    def show
      render json: @group
    end

    def destroy
      render json: @group.destroy
    end

    private

    def group_params
      params.require(:group).permit(:name, :public)
    end

    def load_group
      @group = current_user.groups.where(id: params[:id])
    end
  end
end
