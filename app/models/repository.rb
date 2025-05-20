class Repository < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  belongs_to :user

  enum :visibility, { is_private: 0, is_public: 1 }

  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, message: "is already taken" }
  validates :slug, uniqueness: { scope: :user_id }

  def should_generate_new_friendly_id?
    name_changed?
  end

  def normalize_friendly_id(value)
    value.to_s.parameterize
  end
end
