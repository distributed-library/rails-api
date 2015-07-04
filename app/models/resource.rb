class Resource
  include Mongoid::Document
  include AASM

  field :name, type: String
  field :resource_type, type: String
  field :user_id, type: String 
  field :issuer_id, type: String
  field :aasm_state
  field :isbn_number

  belongs_to :user
  has_and_belongs_to_many :groups

  aasm do
    state :available, initial: true
    state :issued
    state :pending_approval

    event :issue do
      transitions :from => :available, :to => :pending_approval
    end

    event :confirm_issue do
      transitions :from => :pending_approval, :to => :issue
    end

    event :cancel do
      transitions :from => :pending_approval, :to => :available
    end
  end

  def owner_name
    self.user ? self.user.username : ''
  end

  def issuer_name
    if self.issued? || self.pending_approval? 
      user = User.where(id: issuer_id).first
      user ? user.username : ''
    end
  end
end
