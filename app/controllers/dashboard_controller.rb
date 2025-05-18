class DashboardController < ApplicationController
  layout 'dashboard'  # uses layouts/dashboard.html.erb
  before_action :authenticate_user!
  
  def index; end
  def starred; end
  def explore; end
  def settings; end
  def repository; end
end
  