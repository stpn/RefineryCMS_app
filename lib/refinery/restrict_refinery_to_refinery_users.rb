module RestrictRefineryToRefineryUsers

  def restrict_refinery_to_refinery_users
    return if current_user && current_user.has_role?(:refinery) #current_user.try(:roles).try(:empty?) is another possibility
    redirect_to main_app.root_path #this user is not a refinery user because they have no refinery roles.
    return false
  end

end