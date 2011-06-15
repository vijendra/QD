module Admin::QdProfilesHelper

  def dealers_list(admin)
    if super_admin?
      Dealer.dealers_list
    else
      admin.dealers.collect{|dealer| [dealer.profile.name, dealer.id] }
    end
  end

  def check_for_pending_append
    dealer_ids = current_user.dealers.collect(&:id)
    return false if dealer_ids.blank?
    return DataAppend.find(:first, :conditions => ['status_message = ? and dealer_id in (?)', 'sent', dealer_ids ])? true : false
  end

end

