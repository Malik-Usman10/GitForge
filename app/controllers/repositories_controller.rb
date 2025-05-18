# app/controllers/repositories_controller.rb
class RepositoriesController < ApplicationController
    before_action :authenticate_user!, except: [:show]
    before_action :set_user_and_repository, only: [:show]
    before_action :set_repository, only: [:edit, :update, :destroy]
    before_action :authenticate_owner!, only: [:edit, :update, :destroy]
    layout :determine_layout
  
    def index
      @repositories = current_user.repositories.order(updated_at: :desc)
    end
  
    def show
      if @repository.is_private? && current_user != @user
        redirect_to root_path, alert: "This repository is private."
        return
      end
  
    #   readme_file = @repository.files.find_by(name: 'README.md')
    #   @readme_content = readme_file&.content
    end
  
    def new
      @repository = current_user.repositories.new
    end
  
    def create
      @repository = current_user.repositories.new(repository_params)
      if @repository.save
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
  
    private
  
    def repository_params
      params.require(:repository).permit(:name, :description, :visibility, :language, :private)
    end
  
    def set_user_and_repository
      @user = User.find_by!(username: params[:username])
      @repository = @user.repositories.friendly.find(params[:repository_name])
    end
  
    def set_repository
      @repository = current_user.repositories.friendly.find(params[:id])
    end
  
    def authenticate_owner!
      redirect_to root_path, alert: "Unauthorized access." unless current_user == @repository.user
    end
  
    def determine_layout
      if action_name == 'show'
        user_signed_in? ? 'dashboard' : 'application'
      else
        'dashboard'
      end
    end
  end
  