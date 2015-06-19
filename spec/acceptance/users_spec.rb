require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Users' do
  before do
    @user = FactoryGirl.create(:user)
    header "Accept", "application/json; version=1"
    header "Authorization", "Bearer #{token(@user)}"
  end


  get "/users/:id" do
    let(:id){@user.id}
    
    example_request 'Get user' do
      expect(path).to eq("/users/#{@user.id}")
      expect(status).to eq(200)
      expect(json['user']['username']).to eq(@user.username)
    end
  end

end
