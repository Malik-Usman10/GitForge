class UpdateRepositorySlugs < ActiveRecord::Migration[8.0]
  def up
    Repository.find_each do |repo|
      # Simply use the parameterized name as the slug
      repo.update_column(:slug, repo.name.parameterize)
    end
  end

  def down
    # No need to revert as we're just cleaning up slugs
  end
end 