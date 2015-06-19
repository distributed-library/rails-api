FactoryGirl.define do
  sequence(:username) {|n| "test_username_#{n}"}
  sequence(:email) {|n| "test_email#{n}@example.com"}
  factory :user do
    username {FactoryGirl.generate :username}
    email    {FactoryGirl.generate :email}
    password '12345678'
  end
end
