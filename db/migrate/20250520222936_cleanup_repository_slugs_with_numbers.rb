class CleanupRepositorySlugsWithNumbers < ActiveRecord::Migration[8.0]
  def up
    # Group repositories by user_id and name to handle duplicates
    Repository.find_each do |repo|
      base_slug = repo.name.parameterize
      # Find all repositories with the same base name for this user
      same_name_repos = Repository.where(user_id: repo.user_id)
                                 .where("slug LIKE ?", "#{base_slug}%")
                                 .order(:created_at)
      
      # If this is not the first repository with this name, add a number
      if same_name_repos.first != repo
        index = same_name_repos.index(repo)
        new_slug = "#{base_slug}-#{index + 1}"
        repo.update_column(:slug, new_slug)
      else
        # For the first repository, just use the base slug
        repo.update_column(:slug, base_slug)
      end
    end
  end

  def down
    # No need for down migration as we're cleaning up data
  end
end
