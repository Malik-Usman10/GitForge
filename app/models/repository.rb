class Repository < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  belongs_to :user
  has_many :repository_files, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_many :pull_requests, dependent: :destroy
  has_many :commits, dependent: :destroy

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

  def git_path
    Rails.root.join('repos', user.username, "#{slug}.git")
  end

  def readme
    # Try to find README.md first
    readme = repository_files.find_by("LOWER(name) = ?", 'readme.md')
    return readme if readme

    # If not found, try README (without extension)
    readme = repository_files.find_by("LOWER(name) = ?", 'readme')
    return readme if readme

    # If still not found, try any file that starts with README
    repository_files.find_by("LOWER(name) LIKE ?", 'readme%')
  end

  def root_files
    repository_files.root_files
  end

  def url
    # This would be the URL to the repository on the site
    # For now, we'll just return a placeholder
    "/#{user.username}/#{slug}"
  end
end
