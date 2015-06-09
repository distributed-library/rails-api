class Resource
  include Mongoid::Document

  field :resource_type, type: String
  field :user_id, type: Integer 
  
  belongs_to :user
  has_and_belongs_to_many :groups
end
