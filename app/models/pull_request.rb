class PullRequest < ApplicationRecord
  belongs_to :repository
  belongs_to :user

  enum :status, { open: 0, merged: 1, closed: 2 }

  validates :title, :status, presence: true
end
