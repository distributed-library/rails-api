module User::Auth

  def session_auth(params)
    case params[:provider]
    when 'google'
      google_auth params 
    else
      database_auth(params[:session][:email], params[:session][:password])
    end
  end

  def database_auth(email, password)
    user = User.where(email: email).first
    return [user, true] if user && user.valid_password?(password) && user.confirmed?
    return [user, false]
  end

  def google_auth(params)
    options = {redirect_url: params[:redirect_url], auth_code: params[:auth_code], grant_type: 'authorization_code'}
    auth_options = google_auth_options options
    # Get Google Access token using Oauth token
    response = HTTParty.post('https://accounts.google.com/o/oauth2/token', auth_options)

    if response.code == 200
      google_user = get_google_user(response)
      user = get_user params[:user_id], google_user['email'], google_user['id'], 'google'

      # Add google authorization for user
      create_or_update_authorization(user, 'google', google_user)
      return [user, true]
    else
      return [user, false]
    end
  rescue
    return [user, false]
  end

  # Refresh google access token using refresh_token
=begin
  def refresh_google_token(user)
    auth_options = google_auth_options({grant_type: 'refresh_token'})
    response = HTTParty.post('https://www.googleapis.com/oauth2/v3/token', auth_options)
    if response.code == 200
      google_user = get_google_user(response)
      # Update google authorization for user
      create_or_update_authorization(user, 'google', google_user)
    end
  end
=end

  def find_user_from_authentications(options)
    # First check if authentication with given uid is present. If authentication present then find user for that
    # authentication else check if user with given email is present or not
    return User.joins(:authentications).where("authentications.uid = ? AND authentications.provider = ?", options[:uid], options[:provider]).first || User.where(email: options[:email]).first
  end

  def create_user(options)
    user = User.new(
      email: options[:email],
      username: options[:email],
      password: Devise.friendly_token
    )
    user.skip_confirmation! unless options[:provider] == 'twitter'
    user.save!
    return user
  end

  def create_or_update_authorization(user, provider, options, handle=nil)
    user.authentications.find_or_create_by(provider: provider).tap do |auth| 
      auth.uid = options["id"]
      auth.access_token= options[:access_token]
      auth.secret_token= options[:secret_token] if options[:secret_token]
      auth.expires_in = options[:expires_in] if options[:expires_in]
      auth.refresh_token = options[:refresh_token] if options[:refresh_token]
      auth.save!
    end
  end

  def google_auth_options(options)
    {
      body: {
        code: options[:auth_code],
        client_id: Google::CLIENT_ID,
        client_secret: Google::CLIENT_SECRET,
        redirect_uri: options[:redirect_url],
        grant_type: options[:grant_type],
        refresh_token: options[:refresh_token]
      },
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
    }
  end

  def get_google_user(response)
    user = {}
    user[:access_token] = response.parsed_response['access_token']
    user[:expires_in] = DateTime.now + response.parsed_response['expires_in'].seconds
    user[:refresh_token] = response.parsed_response['refresh_token']
    # Get user info using Access Token
    info = HTTParty.get("https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token="+user[:access_token])
    user.merge!(info.parsed_response)
  end
 
  def get_user(user_id, email, uid, provider)
    options = {email: email, uid: uid, provider: provider}
    user = find_user_from_authentications(options)
    return user if user
    # If user doesnot exist then create new user
    user_id.present? ? User.find(user_id) : create_user(options)
  end

end
