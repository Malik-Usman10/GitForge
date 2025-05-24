class CommitsController < ApplicationController
  before_action :set_repository, only: [:index]
  before_action :set_commit, only: [:show]
  
  def index
    # If repository is specified, show commits for that repository
    if @repository
      @commits = Commit.where(repository: @repository).order(created_at: :desc).page(params[:page]).per(20)
    else
      # Otherwise show all commits from repositories the user has access to
      user_repositories = current_user.repositories
      @commits = Commit.where(repository: user_repositories).order(created_at: :desc).page(params[:page]).per(20)
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
    redirect_to commits_path, alert: "Commit not found."
  end
end 