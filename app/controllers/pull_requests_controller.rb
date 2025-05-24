class PullRequestsController < ApplicationController
  before_action :set_pull_request, only: [:show, :edit, :update, :destroy, :merge, :close, :reopen]
  before_action :set_repositories, only: [:new, :edit, :create, :update]
  before_action :set_repository_from_params, only: [:index, :new, :create]
  before_action :set_layout
  
  def index
    if @repository
      # Repository-specific pull requests
      @pull_requests = @repository.pull_requests.includes(:user).order(created_at: :desc)
    elsif params[:username]
      # User-specific pull requests
      user = User.find_by!(username: params[:username])
      @pull_requests = user.pull_requests.includes(:repository).order(created_at: :desc)
    else
      # Current user's pull requests
      @pull_requests = current_user.pull_requests.includes(:repository).order(created_at: :desc)
    end
  end
  
  def show
  end
  
  def new
    @pull_request = PullRequest.new
    @pull_request.status = :open # Set default status to open
    
    # Pre-select repository if provided in params
    if @repository
      @pull_request.repository = @repository
    else
      @pull_request.repository_id = params[:repository_id] if params[:repository_id]
    end
  end
  
  def edit
  end
  
  def create
    @pull_request = current_user.pull_requests.new(pull_request_params)
    @pull_request.status = :open unless @pull_request.status.present? # Ensure status is set
    
    if @pull_request.save
      if params[:username] && params[:repository_name]
        redirect_to user_repository_pull_request_path(username: params[:username], repository_name: params[:repository_name], id: @pull_request.id), notice: 'Pull request was successfully created.'
      else
        redirect_to pull_request_path(@pull_request), notice: 'Pull request was successfully created.'
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    if @pull_request.update(pull_request_params)
      if params[:username] && params[:repository_name]
        redirect_to user_repository_pull_request_path(username: params[:username], repository_name: params[:repository_name], id: @pull_request.id), notice: 'Pull request was successfully updated.'
      else
        redirect_to pull_request_path(@pull_request), notice: 'Pull request was successfully updated.'
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @pull_request.destroy
    
    if params[:username] && params[:repository_name]
      redirect_to user_repository_pull_requests_path(username: params[:username], repository_name: params[:repository_name]), notice: 'Pull request was successfully deleted.'
    else
      redirect_to pull_requests_path, notice: 'Pull request was successfully deleted.'
    end
  end
  
  def merge
    # In a real app, this would handle the actual merging of code
    @pull_request.update(status: :merged)
    
    if params[:username] && params[:repository_name]
      redirect_to user_repository_pull_request_path(username: params[:username], repository_name: params[:repository_name], id: @pull_request.id), notice: 'Pull request was merged.'
    else
      redirect_to pull_request_path(@pull_request), notice: 'Pull request was merged.'
    end
  end
  
  def close
    @pull_request.closed!
    
    if params[:username] && params[:repository_name]
      redirect_to user_repository_pull_request_path(username: params[:username], repository_name: params[:repository_name], id: @pull_request.id), notice: 'Pull request was closed.'
    else
      redirect_to pull_request_path(@pull_request), notice: 'Pull request was closed.'
    end
  end
  
  def reopen
    @pull_request.open!
    
    if params[:username] && params[:repository_name]
      redirect_to user_repository_pull_request_path(username: params[:username], repository_name: params[:repository_name], id: @pull_request.id), notice: 'Pull request was reopened.'
    else
      redirect_to pull_request_path(@pull_request), notice: 'Pull request was reopened.'
    end
  end
  
  private
  
  def set_pull_request
    @pull_request = PullRequest.find(params[:id])
    @repository = @pull_request.repository
  end
  
  def set_repositories
    @repositories = current_user.repositories.order(:name)
  end
  
  def set_repository_from_params
    if params[:username] && params[:repository_name]
      user = User.find_by!(username: params[:username])
      @repository = user.repositories.friendly.find(params[:repository_name])
    end
  end
  
  def pull_request_params
    params.require(:pull_request).permit(:title, :description, :repository_id, :status, :source_branch, :target_branch)
  end
  
  def set_layout
    layout = user_signed_in? ? 'dashboard' : 'application'
    self.class.layout layout
  end
end 