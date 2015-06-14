module V1
  class SessionsController < ApiController
    skip_before_filter :validate_token!

    respond_to :json

    def create
      @user, login = User.session_auth(permit_params)
      if login# && @user.confirmed?
        success_login
      else
        invalid_login
      end
    end

    def forgot_password
      user = User.find_by_email(params[:email])
      user.send_reset_password_instructions if user.present?
      render json: {success: true}, status: 200
    end

    def reset_password
      if params[:user][:password] && params[:user][:password] == params[:user][:password_confirmation]
        @user = User.reset_password_by_token(params[:user])
        if @user.persisted? 
          success_login
        else
          invalid_login
        end
      else
        invalid_login
      end
    end

    def success_login
      token = sign_in_and_return_token
      render json: {
        info: "Logged in",
        username: @user.username,
        email: @user.email,
        user_id: @user.id.to_s,
        token: token 
      },
      status: :created
    end

    def invalid_login
      render :status => :unauthorized,
        json: { 
        :success => false,
        :error => { 
          :email => @user ? '' : "Invalid",
          :password => "Invalid"
        }
      }
    end

    def sign_in_and_return_token
      sign_in @user
      # Generate JWT token here
      token = JWT.encode({"exp" => 4.week.from_now.to_i, "user_id" => @user.id.to_s}, Rails.application.secrets.secret_key_base)
    end

    def permit_params
      params.permit(:auth_code, :handle, :token, :email, :provider, :redirect_url, :user_id, user: [:email, :password])
    end

  end
end
