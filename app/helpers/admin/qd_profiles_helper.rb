module Admin::QdProfilesHelper

  def dealers_list(admin)
    if super_admin?
      Dealer.dealers_list
    else
      admin.dealers.collect{|dealer| [dealer.profile.name, dealer.id] }
    end
  end

end
