class RepositoryFile < ApplicationRecord
  belongs_to :repository
  belongs_to :parent, class_name: 'RepositoryFile', optional: true
  has_many :children, class_name: 'RepositoryFile', foreign_key: 'parent_id', dependent: :destroy

  validates :name, presence: true
  validates :path, presence: true, uniqueness: { scope: :repository_id }
  validates :file_type, presence: true
  validates :is_directory, inclusion: { in: [true, false] }

  scope :root_files, -> { where(parent_id: nil) }
  scope :directories, -> { where(is_directory: true) }
  scope :files, -> { where(is_directory: false) }

  def readme?
    name.downcase == 'readme.md'
  end

  def markdown?
    name.downcase.end_with?('.md')
  end

  def full_path
    path
  end

  def content
    return nil if is_directory

    begin
      repo = Rugged::Repository.new(repository.git_path)
      commit = repo.last_commit
      blob = repo.blob_at(commit.oid, path)
      blob&.content
    rescue => e
      Rails.logger.error "Error reading file content: #{e.message}"
      nil
    end
  end
end
