class Commit < ApplicationRecord
  belongs_to :repository
  belongs_to :user, optional: true
  
  validates :sha, :message, presence: true
  validates :sha, uniqueness: { scope: :repository_id }
  
  # Add Kaminari pagination
  paginates_per 20
  
  def short_sha
    sha.first(7)
  end
  
  def commit_url
    "#{repository.url}/commit/#{sha}"
  end
end 