class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :group_ids
end
