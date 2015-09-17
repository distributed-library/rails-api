module V1
  class MembersController < ApiController
    respond_to :json
    before_action :load_group

    def index
      render json: @group.users
    end

    private

    def load_group
      @group = Group.where(id: params[:group_id]).first
    end

  end
end
