class DashboardController < ApplicationController
  layout 'dashboard'  # uses layouts/dashboard.html.erb
  before_action :authenticate_user!
  
  def index
    # Fetch repository count
    @repository_count = current_user.repositories.count
    
    # Fetch open issues count
    @open_issues_count = Issue.where(user: current_user, status: :open).count
    
    # Fetch pull requests count
    @pull_requests_count = PullRequest.where(user: current_user).count
    
    # Fetch recent commits count
    @commits_count = Commit.joins(:repository).where(repositories: { user_id: current_user.id }).count
    
    # Fetch recent activity (combine repositories, issues, and pull requests)
    @recent_activities = collect_recent_activities
  end
  
  def starred; end
  def explore; end
  def settings; end
  def repository; end
  
  private
  
  def collect_recent_activities
    # Combine recent repositories, issues, pull requests, and commits
    # Sort by creation date and limit to 10 items
    repositories = current_user.repositories.order(created_at: :desc).limit(5).map do |repo|
      {
        type: 'repository',
        user: current_user,
        repository: repo,
        action: 'created',
        created_at: repo.created_at,
        item: repo
      }
    end
    
    # Get opened issues
    opened_issues = Issue.where(user: current_user, status: :open).order(created_at: :desc).limit(5).map do |issue|
      # Check if this is a newly created issue or a reopened one by comparing timestamps
      action = (issue.created_at.to_i == issue.updated_at.to_i) ? 'opened' : 'reopened'
      {
        type: 'issue',
        user: current_user,
        repository: issue.repository,
        action: action,
        created_at: action == 'opened' ? issue.created_at : issue.updated_at,
        item: issue
      }
    end
    
    # Get closed issues - use updated_at as the timestamp for when they were closed
    closed_issues = Issue.where(user: current_user, status: :closed).order(updated_at: :desc).limit(5).map do |issue|
      {
        type: 'issue',
        user: current_user,
        repository: issue.repository,
        action: 'closed',
        created_at: issue.updated_at, # Use updated_at as our timestamp for the closure
        item: issue,
        close_reason: issue.close_reason
      }
    end
    
    # Combine opened and closed issues
    issues = opened_issues + closed_issues
    
    pull_requests = PullRequest.where(user: current_user).order(created_at: :desc).limit(5).map do |pr|
      {
        type: 'pull_request',
        user: current_user,
        repository: pr.repository,
        action: 'opened',
        created_at: pr.created_at,
        item: pr
      }
    end
    
    commits = Commit.joins(:repository)
                   .where(repositories: { user_id: current_user.id })
                   .order(created_at: :desc)
                   .limit(5)
                   .map do |commit|
      {
        type: 'commit',
        user: commit.user || current_user,
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
  