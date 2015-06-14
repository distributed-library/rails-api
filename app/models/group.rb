class Group
  include Mongoid::Document
  field :name, type: String
  field :public, type: Mongoid::Boolean
  field :owner_id, type: String
  has_and_belongs_to_many :users
  has_and_belongs_to_many :resources
end
