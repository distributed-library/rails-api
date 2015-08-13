class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :group_ids, :first_name, :last_name, :email, :profile_picture, :short_bio
end
