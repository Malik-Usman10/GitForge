class UsersController < ApplicationController
  # Skip authentication for the show action
  skip_before_action :authenticate_user!, only: [:show], if: -> { !user_signed_in? }
  
  # Set layout based on authentication status
  layout :determine_layout
  
  def show
    @user = User.find_by!(username: params[:username])
    
    # If current user is viewing their own profile, show all repositories
    # Otherwise, show only public repositories
    if user_signed_in? && current_user == @user
      @repositories = @user.repositories.order(updated_at: :desc)
      @is_current_user = true
      @user_activities = collect_user_activities(@user)
    else
      @repositories = @user.repositories.where(visibility: :is_public).order(updated_at: :desc)
      @is_current_user = false
      @user_activities = collect_public_user_activities(@user)
    end
    
    # Get contribution data
    @total_contributions = calculate_contributions(@user)
    
    # Set active tab
    @active_tab = params[:tab] == 'activity' ? 'activity' : 'repositories'
  end
  
  private
  
  def determine_layout
    if user_signed_in?
      'dashboard'
    else
      'profile'
    end
  end
  
  def calculate_contributions(user)
    # This is a simplified version - in a real app you might track commits, PRs, etc.
    # For now we'll just count repositories and when they were created
    contributions = {}
    
    # Get all repositories created in the last year
    repos_by_month = user.repositories.where('created_at > ?', 1.year.ago)
                         .group_by { |repo| repo.created_at.beginning_of_month }
    
    # Create a hash of month => count
    12.times do |i|
      date = i.months.ago.beginning_of_month
      contributions[date] = repos_by_month[date]&.count || 0
    end
    
    contributions
  end
  
  def collect_user_activities(user)
    # For the user's own view, show all activities
    collect_all_user_activities(user)
  end
  
  def collect_public_user_activities(user)
    # For other viewers, only show activities on public repositories
    public_repos = user.repositories.where(visibility: :is_public)
    
    # Get repositories created
    repositories = public_repos.order(created_at: :desc).limit(5).map do |repo|
      {
        type: 'repository',
        user: user,
        repository: repo,
        action: 'created',
        created_at: repo.created_at,
        item: repo
      }
    end
    
    # Get issues - only from public repos
    issues = Issue.where(user: user)
                  .joins(:repository)
                  .where(repositories: { visibility: :is_public })
                  .order(created_at: :desc)
                  .limit(10)
                  .map do |issue|
      # Determine if it's opened, closed, or reopened
      if issue.status == 'closed'
        action = 'closed'
      else
        # Check timestamps to determine if reopened
        action = (issue.created_at.to_i == issue.updated_at.to_i) ? 'opened' : 'reopened'
      end
      
      {
        type: 'issue',
        user: user,
        repository: issue.repository,
        action: action,
        created_at: action == 'opened' ? issue.created_at : issue.updated_at,
        item: issue,
        close_reason: issue.close_reason
      }
    end
    
    # Get pull requests - only from public repos
    pull_requests = PullRequest.where(user: user)
                              .joins(:repository)
                              .where(repositories: { visibility: :is_public })
                              .order(created_at: :desc)
                              .limit(5)
                              .map do |pr|
      {
        type: 'pull_request',
        user: user,
        repository: pr.repository,
        action: 'opened',
        created_at: pr.created_at,
        item: pr
      }
    end
    
    # Get commits - only from public repos
    commits = Commit.joins(:repository)
                   .where(repositories: { user_id: user.id, visibility: :is_public })
                   .order(created_at: :desc)
                   .limit(5)
                   .map do |commit|
      {
        type: 'commit',
        user: commit.user || user,
        repository: commit.repository,
        action: 'committed',
        created_at: commit.created_at,
        item: commit
      }
    end
    
    # Combine and sort by creation date
    (repositories + issues + pull_requests + commits).sort_by { |activity| activity[:created_at] }.reverse.take(10)
  end
  
  def collect_all_user_activities(user)
    # For the user's own view, show all activities from all repositories
    
    # Get repositories created
    repositories = user.repositories.order(created_at: :desc).limit(5).map do |repo|
      {
        type: 'repository',
        user: user,
        repository: repo,
        action: 'created',
        created_at: repo.created_at,
        item: repo
      }
    end
    
    # Get all issues
    issues = Issue.where(user: user).order(updated_at: :desc).limit(10).map do |issue|
      # Determine if it's opened, closed, or reopened
      if issue.status == 'closed'
        action = 'closed'
      else
        # Check timestamps to determine if reopened
        action = (issue.created_at.to_i == issue.updated_at.to_i) ? 'opened' : 'reopened'
      end
      
      {
        type: 'issue',
        user: user,
        repository: issue.repository,
        action: action,
        created_at: action == 'opened' ? issue.created_at : issue.updated_at,
        item: issue,
        close_reason: issue.close_reason
      }
    end
    
    # Get all pull requests
    pull_requests = PullRequest.where(user: user).order(created_at: :desc).limit(5).map do |pr|
      {
        type: 'pull_request',
        user: user,
        repository: pr.repository,
        action: 'opened',
        created_at: pr.created_at,
        item: pr
      }
    end
    
    # Get all commits
    commits = Commit.joins(:repository)
                   .where(repositories: { user_id: user.id })
                   .order(created_at: :desc)
                   .limit(5)
                   .map do |commit|
      {
        type: 'commit',
        user: commit.user || user,
        repository: commit.repository,
        action: 'committed',
        created_at: commit.created_at,
        item: commit
      }
    end
    
    # Combine and sort by creation date
    (repositories + issues + pull_requests + commits).sort_by { |activity| activity[:created_at] }.reverse.take(10)
  end
end 