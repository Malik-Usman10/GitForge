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

  after_create :initialize_git_repo

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
  
  def sync
    GitSyncService.new(self).sync
  end
  
  private
  
  def initialize_git_repo
    # Create repository directory
    repo_path = git_path
    FileUtils.mkdir_p(File.dirname(repo_path))
    
    # Initialize bare Git repository
    system("git init --bare #{repo_path}")
    
    # Install post-receive hook
    install_git_hooks
  end
  
  def install_git_hooks
    hooks_dir = File.join(git_path, 'hooks')
    FileUtils.mkdir_p(hooks_dir)
    
    # Copy post-receive hook
    post_receive_template = Rails.root.join('lib', 'templates', 'hooks', 'post-receive')
    post_receive_path = File.join(hooks_dir, 'post-receive')
    
    if File.exist?(post_receive_template)
      FileUtils.cp(post_receive_template, post_receive_path)
      FileUtils.chmod(0755, post_receive_path) # Make executable
    else
      Rails.logger.error "Post-receive hook template not found at #{post_receive_template}"
    end
  end
end
