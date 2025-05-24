class IssuesController < ApplicationController
  before_action :set_issue, only: [:show, :edit, :update, :destroy, :close, :reopen]
  before_action :set_repositories, only: [:new, :edit, :create, :update]
  
  def index
    @issues = current_user.issues.includes(:repository).order(created_at: :desc)
  end
  
  def show
  end
  
  def new
    @issue = Issue.new
    @issue.status = :open # Set default status to open
    # Pre-select repository if provided in params
    @issue.repository_id = params[:repository_id] if params[:repository_id]
  end
  
  def edit
  end
  
  def create
    @issue = current_user.issues.new(issue_params)
    @issue.status = :open unless @issue.status.present? # Ensure status is set
    
    if @issue.save
      redirect_to issue_path(@issue), notice: 'Issue was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    if @issue.update(issue_params)
      redirect_to issue_path(@issue), notice: 'Issue was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @issue.destroy
    redirect_to issues_path, notice: 'Issue was successfully deleted.'
  end
  
  def close
    @issue.closed!
    redirect_to issue_path(@issue), notice: 'Issue was closed.'
  end
  
  def reopen
    @issue.open!
    redirect_to issue_path(@issue), notice: 'Issue was reopened.'
  end
  
  private
  
  def set_issue
    @issue = Issue.find(params[:id])
    @repository = @issue.repository
  end
  
  def set_repositories
    @repositories = current_user.repositories.order(:name)
  end
  
  def issue_params
    params.require(:issue).permit(:title, :description, :repository_id, :status)
  end
end 