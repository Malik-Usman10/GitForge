class UsersController < ApplicationController
  def show
    @user = User.find_by!(username: params[:username])
    @repositories = @user.repositories.where(is_private: false).order(updated_at: :desc)
  end
end 