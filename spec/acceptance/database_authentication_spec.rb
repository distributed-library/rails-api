require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Database Authentication' do
  before do
    @user = FactoryGirl.create(:user)
    header "Accept", "application/json; version=1"
  end

  post "/sessions" do
    parameter 'user[email]', "User's email", required: true
    parameter 'user[password]', "User's password", required: true
    
    let('user[email]') {@user.email}
    let('user[password]') {@user.password}

    example_request 'Sign In'do
      expect(status).to eq(201)
      expect(json['token']).not_to be_empty
    end

   
    # Donot documet this test
    example 'wrong crendential', document: false do
      do_request('user[password]' => 'abcdefg') # override user_params with wrong password
      expect(status).to eq(401)
      expect(json['token']).to eq(nil)
    end

  end


  post "/registrations" do
    parameter 'user[username]', "User's screen_name", required: true
    parameter 'user[email]', "User's email", required: true
    parameter 'user[password]', "User's password", required: true
    parameter 'user[password_confirmation]', "User's password confirmation", required: true

    let('user[username]') { 'test_user'}
    let('user[email]')    { 'test_example@example.com'}
    let('user[password]') { '12345678'}
    let('user[password_confirmation]') { '12345678'}

    example_request 'Sign Up'do
      expect(status).to eq(201)
      expect(json['token']).not_to be_empty #donot sign in user on sign up.
    end
    
    # Donot documet this test
    example 'wrong crendential', document: false do
      do_request('user[password]' => 'abcdefg') # override user_params with wrong password
      expect(status).to eq(422)
      expect(json['token']).to eq(nil)
    end
  end

  post "/forgot_password" do
    parameter 'email', "User's email", required: true
    let('email'){'test_example@example.com'}

    example_request 'Send reset password instruction' do
      expect(status).to eq(200)
    end
  end

  post "/reset_password" do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
      @reset_password_token = @user.send(:set_reset_password_token)
    end
    
    parameter 'user[password]', "User's password", required: true
    parameter 'user[password_confirmation]', "User's password confirmation", required: true
    parameter 'user[reset_password_token]', "User's reset password token", required: true
    
    let('user[password]') { 'abcdefghi'}
    let('user[password_confirmation]') { 'abcdefghi'}
    let('user[reset_password_token]'){@reset_password_token}
    
    example_request 'Reset password with new password' do
      expect(@user.reload.valid_password?('abcdefghi')).to eq(true)
      expect(status).to eq(201)
    end
  end

  # Donot reset password if password donot match
  post "/reset_password" do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
      @reset_password_token = @user.send(:set_reset_password_token)
    end
    
    parameter 'user[password]', "User's password", required: true
    parameter 'user[password_confirmation]', "User's password confirmation", required: true
    parameter 'user[reset_password_token]', "User's reset password token", required: true
    
    let('user[password]') { 'abcdefgh'}
    let('user[password_confirmation]') { 'abcdefghi'}
    let('user[reset_password_token]'){@reset_password_token}
    
    example 'Reset password with new invalid password ', document: false do
      do_request
      expect(status).to eq(401)
    end
  end

  # Donot reset password for invalid reset token
  post "/reset_password" do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
      @reset_password_token = '12345678'
    end
    
    parameter 'user[password]', "User's password", required: true
    parameter 'user[password_confirmation]', "User's password confirmation", required: true
    parameter 'user[reset_password_token]', "User's reset password token", required: true
    
    let('user[password]') { 'abcdefghi'}
    let('user[password_confirmation]') { 'abcdefghi'}
    let('user[reset_password_token]'){@reset_password_token}
    
    example 'Reset password with new invalid password', document: false do
      do_request
      expect(status).to eq(401)
    end
  end


=begin
  # Refresh JWT token not implemented yet
  get "/refresh_token" do
    before do
      header "Accept", "application/json"
      @expired_token = JWT.encode({'exp' => 1.second.ago.to_i, 'user' => @user }, Rails.application.secrets.jwt_key)
      header "Authorization", "Bearer #{@expired_token}"
    end

    example_request "Refresh token" do
      expect(status).to eq(201)
      expect(json['token']).not_to eq(@expired_token)
    end
  end
=end
end
