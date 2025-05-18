class Repository < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :user

  enum :visibility, { is_private: 0, is_public: 1 }

  validates :name, presence: true
  validates :slug, uniqueness: { scope: :user_id }

  def should_generate_new_friendly_id?
    name_changed?
  end
end
