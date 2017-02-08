class CreateUser
  prepend SimpleCommand

  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    user = find_user

    return nil unless user.nil?

    user = create_user

    return nil if user.nil?

    user.token
  end

  private

  attr_accessor :email, :password

  def find_user
    user = User.find_by_email(email)

    errors.add(:user_creation, 'already exists') unless user.nil?

    user
  end

  def create_user
    user = User.new(email: @email, password: @password, token: create_token)

    if user.save
      user
    else
      error.add(:user_creation, 'Unknown error') && nil
    end
  end

  def create_token
    JsonWebToken.encode(token: "#{Time.zone.now}#{@email}")
  end
end
