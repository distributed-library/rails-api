module V1
  class UsersController < ApiController
    before_action :load_group, only: [:join_group]

    def show
      render json: current_user
    end

    def join_group
      @group.user_ids << current_user.id
      render json: @group.save
    end

    private

    def load_group
      @group = Group.find(params[:id])
    end

  end
end
