# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'
csv = CSV.read("#{Rails.root}/book_list.csv", headers: true)
group = Group.find_or_create_by!(name: 'Josh Software')
csv.each do |row|
  if row["Owner"]
    ownername = row["Owner"].parameterize
    user = User.where(username: ownername).first
    unless user
      user = User.create!(username: ownername, email: "#{ownername}@joshsoftware.com", password: 'josh1234', group_ids: [group.id])
    end
    resource = Resource.find_or_create_by(isbn_number: row["Isbn no"], user_id: user.id.to_s, group_ids: [group.id])
    resource.update_attribute('name', row["Name"])
  end
end
