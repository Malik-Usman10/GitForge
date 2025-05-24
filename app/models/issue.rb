class Issue < ApplicationRecord
  belongs_to :repository
  belongs_to :user, optional: true

  enum :status, { open: 0, closed: 1 }

  validates :title, :status, presence: true
  
  # Stores the timestamp when the issue was closed
  def closed_at
    return nil if open?
    # Return updated_at as the closed timestamp if issue is closed
    updated_at
  end
end
