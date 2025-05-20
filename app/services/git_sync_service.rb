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

      # Clear existing files
      @repository.repository_files.destroy_all

      # Walk through the tree
      walk_tree(head.tree, '')
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

  def walk_tree(tree, path)
    tree.each do |entry|
      current_path = path.empty? ? entry[:name] : File.join(path, entry[:name])
      
      if entry[:type] == :tree
        # Create directory
        create_file(entry[:name], current_path, true)
        # Recursively process subdirectory
        walk_tree(entry[:object], current_path)
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
      @repository.repository_files.create!(
        name: name,
        path: path,
        content: content,
        file_type: is_directory ? 'directory' : File.extname(name)[1..] || 'text',
        is_directory: is_directory,
        parent: parent
      )
    rescue => e
      Rails.logger.error "Error creating file record for #{path}: #{e.message}"
    end
  end

  def find_or_create_parent(path)
    return nil if path == File.basename(path)

    parent_path = File.dirname(path)
    parent_name = File.basename(parent_path)
    
    parent = @repository.repository_files.find_by(path: parent_path)
    return parent if parent

    create_file(parent_name, parent_path, true)
  end
end 