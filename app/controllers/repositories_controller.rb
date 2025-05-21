# app/controllers/repositories_controller.rb
class RepositoriesController < ApplicationController
    before_action :authenticate_user!, except: [:show]
    before_action :set_user_and_repository, only: [:show]
    before_action :set_repository, only: [:edit, :update, :destroy, :sync]
    before_action :authenticate_owner!, only: [:edit, :update, :destroy, :sync]
    layout :determine_layout
  
    rescue_from ActiveRecord::RecordNotFound do |exception|
      if exception.model == "Repository"
        redirect_to repositories_path, alert: "Repository not found."
      else
        redirect_to root_path, alert: "Resource not found."
      end
    end

    def index
      @repositories = current_user.repositories.order(updated_at: :desc)
    end
  
    def show
      if @repository.is_private? && current_user != @user
        render :private, status: :forbidden
        return
      end

      # Load all files with their children in a single query
      @files = @repository.repository_files
        .includes(children: { children: { children: { children: :children } } })
        .where(parent_id: nil)
        .order(:name)
      
      # Debug information
      Rails.logger.debug "=== Repository Files Debug ==="
      Rails.logger.debug "Total files in repository: #{@repository.repository_files.count}"
      Rails.logger.debug "Root files count: #{@files.count}"
      @files.each do |file|
        Rails.logger.debug "Root file: #{file.name} (#{file.is_directory ? 'directory' : 'file'})"
        if file.is_directory
          Rails.logger.debug "  Children count: #{file.children.count}"
          file.children.each do |child|
            Rails.logger.debug "    Child: #{child.name} (#{child.is_directory ? 'directory' : 'file'})"
            if child.is_directory
              Rails.logger.debug "      Grandchildren count: #{child.children.count}"
            end
          end
        end
      end
      Rails.logger.debug "==========================="

      @readme = @repository.readme
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
      begin
        # Store the username before destroying the repository
        username = @repository.user.username
        
        # Delete the git repository directory
        FileUtils.rm_rf(@repository.git_path) if Dir.exist?(@repository.git_path)
        
        # Destroy the repository record
        @repository.destroy
        
        # Redirect to user's repositories page
        redirect_to user_repositories_path(username: username), notice: "Repository deleted successfully."
      rescue => e
        Rails.logger.error "Error deleting repository: #{e.message}"
        # On error, still try to redirect to user's repositories if we have the username
        if username.present?
          redirect_to user_repositories_path(username: username), alert: "Failed to delete repository. Please try again."
        else
          redirect_to repositories_path, alert: "Failed to delete repository. Please try again."
        end
      end
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
      begin
        @user = User.find_by!(username: params[:username])
        @repository = @user.repositories.friendly.find(params[:repository_name])
      rescue ActiveRecord::RecordNotFound => e
        if e.model == "User"
          redirect_to root_path, alert: "User not found."
        else
          redirect_to repositories_path, alert: "Repository not found."
        end
      end
    end
  
    def set_repository
      begin
        if params[:id].present?
          @repository = current_user.repositories.friendly.find(params[:id])
        elsif params[:repository_name].present? && params[:username].present?
          @user = User.find_by!(username: params[:username])
          @repository = @user.repositories.friendly.find(params[:repository_name])
        else
          @repository = nil
        end
      rescue ActiveRecord::RecordNotFound => e
        if e.model == "User"
          redirect_to root_path, alert: "User not found."
        else
          redirect_to repositories_path, alert: "Repository not found."
        end
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
  