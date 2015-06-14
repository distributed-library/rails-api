module V1
  class RegistrationsController < Devise::RegistrationsController
    skip_before_filter :validate_token!

    respond_to :json

    def create
      if params[:user]
        create_user
      end
    end

    def create_user
      if params[:user][:user_id].present?
        user = User.find(params[:user][:user_id])
        param = sign_up_params.merge!({anonymous: false})
        user.assign_attributes(param)
      else
        user = User.new(sign_up_params)
      end
      save_return user
    end

    def save_return user
      begin
        # render because devise redirecting to session/new
        user.save! and render json: {success: true} or render_error(user)
        # Any database exceptions handled here
      rescue
        render_error user
      end
    end

    def confirm
      confirmation_token = Devise.token_generator.digest(self, :confirmation_token, params[:token])
      user = User.where(confirmation_token: confirmation_token).first
      if user
        user.confirmation_token = nil
        user.confirmed_at = DateTime.now              
        if User.reconfirmable
          user.skip_reconfirmation!
          user.email = user.unconfirmed_email if user.unconfirmed_email?
          user.unconfirmed_email = nil
        end
        user.save
      end
      render_result(user.present?, user)
    end

    def render_result(saved, user)
      if saved
        render_success user
      else
        render_error user
      end
    end

    def render_success(user)
      sign_in user
      token = JWT.encode({'exp' => 4.week.from_now.to_i, 'user_id' => user.id.to_s }, Rails.application.secrets.jwt_key)
      render json: {
        :success => true,
        :info => "Registered",
        :username => user.username,
        :user_id => current_user.id,
        :email => user.email,
        :token => token, 
      },
      :status => :created
    end

    def render_error user
      render :status => :unprocessable_entity,
        :json => { :success => false,
                   :error => user.present? ? user.errors : ''}
    end

    def sign_up_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end
  end

end
