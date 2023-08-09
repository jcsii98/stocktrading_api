class UserMailer < ApplicationMailer
  def confirmation_email(user)
    @user = user

    mail(
      to: @user.email,
      subject: 'Confirmation Email'
    ) do |format|
      format.text { render plain: confirmation_email_json }
    end
  end

  private

  def confirmation_email_json
    {
      subject: 'Confirmation Email',
      to: @user.email,
      message: 'Welcome to My App!',
      confirmation_token: @user.confirmation_token
    }.to_json
  end
end
