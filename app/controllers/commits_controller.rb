class CommitsController < ApplicationController
  before_action :set_repository, only: [:index]
  before_action :set_commit, only: [:show]
  before_action :set_repository_from_params, only: [:index, :show]
  before_action :set_layout
  
  def index
    # If repository is specified, show commits for that repository
    if @repository
      @commits = Commit.where(repository: @repository).order(created_at: :desc).page(params[:page])
    elsif params[:username]
      # If only username is specified, show all commits from that user's repositories
      user = User.find_by!(username: params[:username])
      user_repositories = user.repositories
      @commits = Commit.where(repository: user_repositories).order(created_at: :desc).page(params[:page])
    else
      # Otherwise show all commits from repositories the current user has access to
      user_repositories = current_user.repositories
      @commits = Commit.where(repository: user_repositories).order(created_at: :desc).page(params[:page])
    end
  end
  
  def show
  end
  
  private
  
  def set_repository
    @repository = Repository.friendly.find(params[:repository_id]) if params[:repository_id]
  end
  
  def set_commit
    @commit = Commit.find(params[:id])
    @repository = @commit.repository
  rescue ActiveRecord::RecordNotFound
    if params[:username] && params[:repository_name]
      redirect_to user_repository_commits_path(username: params[:username], repository_name: params[:repository_name]), alert: "Commit not found."
    else
      redirect_to user_commits_path(current_user.username), alert: "Commit not found."
    end
  end
  
  def set_repository_from_params
    if params[:username] && params[:repository_name]
      user = User.find_by!(username: params[:username])
      @repository = user.repositories.friendly.find(params[:repository_name])
    end
  end
  
  def set_layout
    layout = user_signed_in? ? 'dashboard' : 'application'
    self.class.layout layout
  end
end 