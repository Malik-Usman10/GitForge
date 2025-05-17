class Repository < ApplicationRecord
  belongs_to :user

  enum :visibility, { is_private: 0, is_public: 1 }

  validates :name, :slug, presence: true
  validates :slug, uniqueness: { scope: :user_id }

  before_validation :generate_slug, on: :create

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
