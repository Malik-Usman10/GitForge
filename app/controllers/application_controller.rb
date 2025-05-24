class ApplicationController < ActionController::Base
  # Authenticate users by default
  before_action :authenticate_user!
  
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Redirect to dashboard after sign in
  def after_sign_in_path_for(resource)
    main_app.dashboard_path
  end
end
