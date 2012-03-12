class Users::SessionsController < Devise::SessionsController
  before_filter :block_login_during_maintenance
  def block_login_during_maintenance
   return if !DB_UNDER_MAINTENANCE
   redirect_to db_maintenance_message_path
   return false
  end
end