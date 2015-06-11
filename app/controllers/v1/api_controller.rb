module V1
  class ApiController < ApplicationController
    include ActionController::Serialization
    before_action :validate_token!

    private

    def validate_token!(options = {})
      begin
        if request.headers['Authorization'].present?
          token = request.headers['Authorization'].split(' ').last
          # Claims is a hash list. Can use 'email' and 'id' to find and verify user.
          claims = JWT.decode(token, Rails.application.secrets.secret_key_base, true, options)
          # claims [{"exp"=>"2015-01-13T19:09:21.785Z", "user"=>{"user"=>
          # {"id"=>93, "email"=>"anil@gmail.com", "created_at"=>"2014-12-16T16:42:26.399Z", 
          # "updated_at"=>"2014-12-16T19:09:21.761Z", "username"=>"anil", "anonymous"=>false, 
          # "short_bio"=>nil}}}, {"typ"=>"JWT", "alg"=>"HS256"}]
          set_current_user(claims[0]['user_id'])
        else
          render_invalid_header
        end
      rescue JWT::DecodeError
        render_decode_error
      rescue JWT::ExpiredSignature
        render_expired_signature 
      end
    end

    def current_user
      @current_user
    end

    def render_unauthorized
      @error = {user: "Not Authorized"}
      render_error
    end

    def render_expired_signature
      @error = {token: "Signature expired"}
      render_error
    end

    def render_invalid_header
      @error = {:success => false, :header => "No Authorization header"}
      render_error
    end

    def render_decode_error
      @error = {token: "Invalid token"}
      render_error
    end

    def render_error
      render json: {
        errors: @error
      }, status: :unauthorized
    end

    def set_current_user(user_id)
      @current_user = User.find(user_id)
    end

  end
end
