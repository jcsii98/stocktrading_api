class UsersService
  def self.get_pending_users
    User.where(account_pending: true)
  end

  def self.get_pending_user_by_id(id)
    User.find_by(id: id, account_pending: true)
  end

  def self.get_all_users
    User.all
  end

  def self.get_user_by_id(id)
    User.find_by(id: id)
  end

  def self.response_user_attributes(user)
    {
      id: user.id,
      full_name: user.full_name,
      email: user.email,
      account_pending: user.account_pending
    }
  end
end
