class Issue < ApplicationRecord
  belongs_to :repository
  belongs_to :user, optional: true

  enum :status, { open: 0, closed: 1 }

  validates :title, :status, presence: true
end
