class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :owner_id
end
