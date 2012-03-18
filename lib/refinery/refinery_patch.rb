module RefineryPatch

  def self.included(base)
    base.send :helper_method,
              :current_refinery_user,
              :refinery_user_signed_in?,
              :refinery_user? if base.respond_to? :helper_method
  end

  def current_refinery_user
    current_user
  end

  def just_installed?
    Role[:refinery].users.empty?
  end

  def refinery_user_signed_in?
    user_signed_in?
  end

  def refinery_user?
    refinery_user_signed_in? && current_refinery_user.has_role?(:refinery)
  end

  def authenticate_refinery_user!
    authenticate_user!
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

protected
  def refinery_user_required?
    if just_installed? and %w[registrations users].exclude?(controller_name)
      redirect_to main_app.new_user_registration_path
    end
  end
end