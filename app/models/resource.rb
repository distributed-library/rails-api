class Resource
  include Mongoid::Document

  field :resource_type, type: String
  field :user_id, type: Integer 
  
  belongs_to :user
end
