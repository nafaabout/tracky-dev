# frozen_string_literal: true

# == Schema Information
#
# Table name: articles
#
#  id           :uuid             not null, primary key
#  author       :jsonb
#  published_at :datetime
#  title        :string
#  url          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  platform_id  :uuid             not null
#  remote_id    :integer
#
# Indexes
#
#  index_articles_on_platform_id  (platform_id)
#
# Foreign Keys
#
#  fk_rails_...  (platform_id => platforms.id)
#
class Article < ApplicationRecord
  belongs_to :platform
  has_many :tag_articles
  has_many :tags, through: :tag_articles
end
