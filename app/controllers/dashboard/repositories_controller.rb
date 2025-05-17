class Dashboard::RepositoriesController < ApplicationController
  layout 'dashboard'
  before_action :authenticate_user!
  
  def index
    @repositories = current_user.repositories.order(updated_at: :desc)
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
