# Clear existing records
PullRequest.delete_all
Issue.delete_all
Repository.delete_all
User.delete_all

puts "🧹 Cleared existing records..."

# Create a sample user
user = User.create!(
  username: 'johnsmith1',
  real_name: 'John Smith',
  email: 'john1@example.com',
  password: 'password',
  bio: 'Ruby developer and open-source contributor.'
)

puts "✅ Created user: #{user.username}"

# Create a sample repository
repo = user.repositories.create!(
  name: 'awesome-repoTwo',
  description: 'My Second GitForge repo',
  language: 'JavaScript',
  visibility: :is_private
)

puts "📁 Created repository: #{repo.name}"

# # Create a sample issue
# issue = repo.issues.create!(
#   title: 'Fix UI bug',
#   description: 'Navbar issue on mobile view',
#   status: :open,
#   user: user
# )

# puts "🐞 Created issue: #{issue.title}"

# # Create a sample pull request
# pr = repo.pull_requests.create!(
#   title: 'Add dark mode support',
#   description: 'Implemented dark mode toggle in navbar',
#   status: :open,
#   source_branch: 'feature/dark-mode',
#   target_branch: 'main',
#   user: user
# )

# puts "🚀 Created pull request: #{pr.title}"

# puts "🎉 Seeding complete!"
