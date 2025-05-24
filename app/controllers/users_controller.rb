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
    else
      @repositories = @user.repositories.where(visibility: :is_public).order(updated_at: :desc)
      @is_current_user = false
    end
    
    # Get contribution data
    @total_contributions = calculate_contributions(@user)
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
end 