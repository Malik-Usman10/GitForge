# app/controllers/repositories_controller.rb
class RepositoriesController < ApplicationController
    before_action :authenticate_user!, except: [:show]
    before_action :set_user_and_repository, only: [:show]
    before_action :set_repository, only: [:edit, :update, :destroy, :sync]
    before_action :authenticate_owner!, only: [:edit, :update, :destroy, :sync]
    layout :determine_layout
  
    def index
      @repositories = current_user.repositories.order(updated_at: :desc)
    end
  
    def show
      if @repository.is_private? && current_user != @user
        render :private, status: :forbidden
        return
      end

      @files = @repository.root_files.includes(:children)
      @readme = @repository.readme
      
      Rails.logger.debug "Repository files count: #{@repository.repository_files.count}"
      Rails.logger.debug "Root files count: #{@files.count}"
      Rails.logger.debug "README found: #{@readme.present?}"
      Rails.logger.debug "README content: #{@readme&.content}" if @readme
    end
  
    def new
      @repository = current_user.repositories.new
    end
  
    def create
      @repository = current_user.repositories.new(repository_params)
      if @repository.save
        # Initialize git repository
        initialize_git_repo
        redirect_to user_repository_path(username: current_user.username, repository_name: @repository.slug), notice: "Repository created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    def edit
    end
  
    def update
      if @repository.update(repository_params)
        redirect_to user_repository_path(username: current_user.username, repository_name: @repository.slug), notice: "Repository updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  
    def destroy
      @repository.destroy
      redirect_to repositories_path, notice: "Repository deleted."
    end

    def sync
      Rails.logger.debug "GitSyncService defined? #{defined?(GitSyncService)}"
      Rails.logger.debug "Repository: #{@repository.inspect}"
      
      if @repository.nil?
        redirect_to repositories_path, alert: "Repository not found."
        return
      end

      if GitSyncService.new(@repository).sync
        redirect_to user_repository_path(username: current_user.username, repository_name: @repository.slug), notice: "Repository synchronized successfully."
      else
        redirect_to user_repository_path(username: current_user.username, repository_name: @repository.slug), alert: "Failed to synchronize repository."
      end
    end
  
    private
  
    def repository_params
      params.require(:repository).permit(:name, :description, :visibility, :language, :private)
    end
  
    def set_user_and_repository
      @user = User.find_by!(username: params[:username])
      @repository = @user.repositories.friendly.find(params[:repository_name])
    end
  
    def set_repository
      if params[:id].present?
        @repository = current_user.repositories.friendly.find(params[:id])
      elsif params[:repository_name].present? && params[:username].present?
        @user = User.find_by!(username: params[:username])
        @repository = @user.repositories.friendly.find(params[:repository_name])
      else
        @repository = nil
      end
    end
  
    def authenticate_owner!
      redirect_to root_path, alert: "Unauthorized access." unless current_user == @repository.user
    end
  
    def determine_layout
      if action_name == 'show' || action_name == 'private'
        user_signed_in? ? 'dashboard' : 'application'
      else
        'dashboard'
      end
    end

    def initialize_git_repo
      repo_path = @repository.git_path
      FileUtils.mkdir_p(File.dirname(repo_path))
      system("git init --bare #{repo_path}")
    end
end
  