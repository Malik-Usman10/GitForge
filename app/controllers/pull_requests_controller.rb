class PullRequestsController < ApplicationController
  before_action :set_pull_request, only: [:show, :edit, :update, :destroy, :merge, :close, :reopen]
  before_action :set_repositories, only: [:new, :edit, :create, :update]
  
  def index
    @pull_requests = current_user.pull_requests.includes(:repository).order(created_at: :desc)
  end
  
  def show
  end
  
  def new
    @pull_request = PullRequest.new
    @pull_request.status = :open # Set default status to open
    # Pre-select repository if provided in params
    @pull_request.repository_id = params[:repository_id] if params[:repository_id]
  end
  
  def edit
  end
  
  def create
    @pull_request = current_user.pull_requests.new(pull_request_params)
    @pull_request.status = :open unless @pull_request.status.present? # Ensure status is set
    
    if @pull_request.save
      redirect_to pull_request_path(@pull_request), notice: 'Pull request was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    if @pull_request.update(pull_request_params)
      redirect_to pull_request_path(@pull_request), notice: 'Pull request was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @pull_request.destroy
    redirect_to pull_requests_path, notice: 'Pull request was successfully deleted.'
  end
  
  def merge
    # In a real app, this would handle the actual merging of code
    @pull_request.update(status: :merged)
    redirect_to pull_request_path(@pull_request), notice: 'Pull request was merged.'
  end
  
  def close
    @pull_request.closed!
    redirect_to pull_request_path(@pull_request), notice: 'Pull request was closed.'
  end
  
  def reopen
    @pull_request.open!
    redirect_to pull_request_path(@pull_request), notice: 'Pull request was reopened.'
  end
  
  private
  
  def set_pull_request
    @pull_request = PullRequest.find(params[:id])
    @repository = @pull_request.repository
  end
  
  def set_repositories
    @repositories = current_user.repositories.order(:name)
  end
  
  def pull_request_params
    params.require(:pull_request).permit(:title, :description, :repository_id, :status, :source_branch, :target_branch)
  end
end 