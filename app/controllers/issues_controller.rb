class IssuesController < ApplicationController
  before_action :set_issue, only: [:show, :edit, :update, :destroy, :close, :reopen]
  before_action :set_repositories, only: [:new, :edit, :create, :update]
  before_action :set_repository_from_params, only: [:index, :new, :create]
  before_action :set_layout
  
  def index
    if @repository
      # Repository-specific issues
      @issues = @repository.issues.includes(:user).order(created_at: :desc)
    elsif params[:username]
      # User-specific issues
      user = User.find_by!(username: params[:username])
      @issues = user.issues.includes(:repository).order(created_at: :desc)
    else
      # Current user's issues
      @issues = current_user.issues.includes(:repository).order(created_at: :desc)
    end
  end
  
  def show
  end
  
  def new
    @issue = Issue.new
    @issue.status = :open # Set default status to open
    
    # Pre-select repository if provided in params
    if @repository
      @issue.repository = @repository
    else
      @issue.repository_id = params[:repository_id] if params[:repository_id]
    end
  end
  
  def edit
  end
  
  def create
    @issue = current_user.issues.new(issue_params)
    @issue.status = :open unless @issue.status.present? # Ensure status is set
    
    if @issue.save
      if params[:username] && params[:repository_name]
        redirect_to user_repository_issue_path(username: params[:username], repository_name: params[:repository_name], id: @issue.id), notice: 'Issue was successfully created.'
      else
        redirect_to issue_path(@issue), notice: 'Issue was successfully created.'
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    if @issue.update(issue_params)
      if params[:username] && params[:repository_name]
        redirect_to user_repository_issue_path(username: params[:username], repository_name: params[:repository_name], id: @issue.id), notice: 'Issue was successfully updated.'
      else
        redirect_to issue_path(@issue), notice: 'Issue was successfully updated.'
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @issue.destroy
    
    if params[:username] && params[:repository_name]
      redirect_to user_repository_issues_path(username: params[:username], repository_name: params[:repository_name]), notice: 'Issue was successfully deleted.'
    else
      redirect_to issues_path, notice: 'Issue was successfully deleted.'
    end
  end
  
  def close
    # Log the parameter to make sure we're receiving it
    Rails.logger.info "Close reason: #{params[:close_reason].inspect}"
    
    @issue.close_reason = params[:close_reason]
    @issue.update(status: :closed, updated_at: Time.current) # Explicitly update timestamp
    
    if params[:username] && params[:repository_name]
      redirect_to user_repository_issue_path(username: params[:username], repository_name: params[:repository_name], id: @issue.id), notice: 'Issue was closed.'
    else
      redirect_to issue_path(@issue), notice: 'Issue was closed.'
    end
  end
  
  def reopen
    # Clear close reason when reopening
    @issue.close_reason = nil
    @issue.update(status: :open, updated_at: Time.current) # Explicitly update timestamp
    
    if params[:username] && params[:repository_name]
      redirect_to user_repository_issue_path(username: params[:username], repository_name: params[:repository_name], id: @issue.id), notice: 'Issue was reopened.'
    else
      redirect_to issue_path(@issue), notice: 'Issue was reopened.'
    end
  end
  
  private
  
  def set_issue
    @issue = Issue.find(params[:id])
    @repository = @issue.repository
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
  
  def issue_params
    params.require(:issue).permit(:title, :description, :repository_id, :status, :close_reason)
  end
  
  def set_layout
    layout = user_signed_in? ? 'dashboard' : 'application'
    self.class.layout layout
  end
end 