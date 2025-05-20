class CleanupRepositorySlugs < ActiveRecord::Migration[8.0]
  def up
    # First, update all slugs to be just the parameterized name
    Repository.find_each do |repo|
      clean_slug = repo.name.parameterize
      # If there's a conflict, add a number
      if Repository.where(user_id: repo.user_id).where.not(id: repo.id).exists?(slug: clean_slug)
        clean_slug = "#{clean_slug}-#{rand(1000)}"
      end
      repo.update_column(:slug, clean_slug)
    end
  end

  def down
    # No need for down migration as we're cleaning up data
  end
end
