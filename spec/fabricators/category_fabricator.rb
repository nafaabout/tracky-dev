# == Schema Information
#
# Table name: categories
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
Fabricator(:category) do
  name { Faker::Cannabis.category }
  topics(rand: 5, fabricator: :topic_with_no_category)
end
