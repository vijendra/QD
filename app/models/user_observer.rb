class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserMailer.deliver_signup_notification(user) if (user.not_using_openid? && !user.activation_code.blank?) #if admin created user activation ode will b empty.
  end

  def after_save(user)
    UserMailer.deliver_activation(user) if user.recently_activated? && user.not_using_openid?
  end
end
