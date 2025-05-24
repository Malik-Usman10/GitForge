require 'rugged'

class GitSyncService
  def initialize(repository)
    @repository = repository
    @repo_path = repository.git_path
  end

  def sync
    return false unless git_repo_exists?

    begin
      # Get the latest commit
      repo = Rugged::Repository.new(@repo_path)
      head = repo.head.target

      Rails.logger.debug "=== Starting Git Sync ==="
      Rails.logger.debug "Repository path: #{@repo_path}"
      Rails.logger.debug "Head commit: #{head.oid}"

      # Sync commits
      sync_commits(repo)

      # Clear existing files
      @repository.repository_files.destroy_all
      Rails.logger.debug "Cleared existing files"

      # Walk through the tree
      walk_tree(head.tree, '')
      
      # Verify sync
      total_files = @repository.repository_files.count
      root_files = @repository.repository_files.where(parent_id: nil).count
      Rails.logger.debug "Sync completed. Total files: #{total_files}, Root files: #{root_files}"
      Rails.logger.debug "=== Git Sync Complete ==="
      
      true
    rescue => e
      Rails.logger.error "Git sync error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      false
    end
  end

  private

  def git_repo_exists?
    Dir.exist?(@repo_path)
  end

  def sync_commits(repo)
    Rails.logger.debug "=== Syncing Commits ==="
    
    # Get existing commit SHAs
    existing_shas = @repository.commits.pluck(:sha)
    
    # Get all branches
    repo.branches.each do |branch|
      # Walk through commits
      walker = Rugged::Walker.new(repo)
      walker.push(branch.target.oid)
      
      # Limit to 100 most recent commits to avoid huge syncs
      count = 0
      walker.each do |commit|
        break if count >= 100
        
        # Skip if we already have this commit
        next if existing_shas.include?(commit.oid)
        
        # Find the commit author in our system
        author_email = commit.author[:email]
        user = User.find_by(email: author_email)
        
        # Create the commit record
        @repository.commits.create(
          sha: commit.oid,
          message: commit.message,
          author_name: commit.author[:name],
          author_email: commit.author[:email],
          user: user,
          committed_at: Time.at(commit.time.to_i),
          created_at: Time.at(commit.time.to_i)
        )
        
        count += 1
        Rails.logger.debug "Synced commit: #{commit.oid[0..7]} - #{commit.message.lines.first.strip}"
      end
    end
    
    Rails.logger.debug "=== Commit Sync Complete ==="
  end

  def walk_tree(tree, path)
    return unless tree

    tree.each do |entry|
      current_path = path.empty? ? entry[:name] : File.join(path, entry[:name])
      Rails.logger.debug "Processing: #{current_path} (#{entry[:type]})"
      
      if entry[:type] == :tree
        # Create directory
        create_file(entry[:name], current_path, true)
        # Get the tree object and recursively process subdirectory
        subtree = entry[:object]
        walk_tree(subtree, current_path) if subtree
      else
        # Create file
        begin
          blob = entry[:object]
          content = blob.content if blob
          create_file(entry[:name], current_path, false, content)
        rescue => e
          Rails.logger.error "Error processing file #{current_path}: #{e.message}"
          # Create the file entry anyway, but without content
          create_file(entry[:name], current_path, false, nil)
        end
      end
    end
  end

  def create_file(name, path, is_directory, content = nil)
    parent = find_or_create_parent(path)
    
    begin
      file = @repository.repository_files.new(
        name: name,
        path: path,
        content: content,
        file_type: is_directory ? 'directory' : File.extname(name)[1..] || 'text',
        is_directory: is_directory,
        parent: parent
      )

      if file.save
        Rails.logger.debug "Created #{is_directory ? 'directory' : 'file'}: #{path}"
      else
        Rails.logger.error "Validation errors for #{path}: #{file.errors.full_messages.join(', ')}"
      end
    rescue => e
      Rails.logger.error "Error creating file record for #{path}: #{e.message}"
    end
  end

  def find_or_create_parent(path)
    return nil if path == File.basename(path)

    parent_path = File.dirname(path)
    parent_name = File.basename(parent_path)
    
    # First try to find the parent
    parent = @repository.repository_files.find_by(path: parent_path)
    return parent if parent

    # If parent doesn't exist, we need to create it and its ancestors
    grandparent = find_or_create_parent(parent_path)
    create_file(parent_name, parent_path, true)
    @repository.repository_files.find_by(path: parent_path)
  end
end 