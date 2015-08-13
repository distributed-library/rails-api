module V1
  class UsersController < ApiController
    before_action :load_user

    def show
      render json: current_user
    end

    def update
      render json: @user.update_attributes(user_params)
    end

    private

    def user_params
      params.require(:user).permit(:username, :email, :password, :first_name, :last_name, :short_bio, :profile_picture);
    end

    def load_user
      @user = User.find(current_user.id);
    end
  end
end
