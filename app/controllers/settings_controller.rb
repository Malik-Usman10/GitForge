class SettingsController < ApplicationController
  before_action :authenticate_user!
  
  def update_profile
    @user = current_user
    
    if @user.update(user_params)
      redirect_to dashboard_settings_path, notice: 'Profile was successfully updated.'
    else
      render 'dashboard/settings', status: :unprocessable_entity
    end
  end
  
  def update_password
    @user = current_user
    
    # Check if current password is correct
    if !@user.valid_password?(params[:user][:current_password])
      @user.errors.add(:current_password, "is incorrect")
      render 'dashboard/settings', status: :unprocessable_entity
      return
    end
    
    # Check if new passwords match
    if params[:user][:password] != params[:user][:password_confirmation]
      @user.errors.add(:password_confirmation, "doesn't match Password")
      render 'dashboard/settings', status: :unprocessable_entity
      return
    end
    
    if @user.update(password_params)
      # Sign in the user bypassing validation in case the password changed
      bypass_sign_in(@user)
      redirect_to dashboard_settings_path, notice: 'Password was successfully updated.'
    else
      render 'dashboard/settings', status: :unprocessable_entity
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :username, :bio, :location, :website, :avatar)
  end
  
  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end