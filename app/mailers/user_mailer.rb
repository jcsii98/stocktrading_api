class UserMailer < ApplicationMailer
  def account_approved(user)
    @user = user
    mail(to: @user.email, subject: 'Your Account Has Been Approved')
  end
end
