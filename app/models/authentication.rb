class Authentication
  include Mongoid::Document
  field :uid, type: String
  field :access_token, type: String
  field :secret_token, type: String
  field :refresh_token, type: String
  field :expires_in, type: Time
  field :provider, type: String
  field :user_id, type: String
  
  belongs_to :user
end
