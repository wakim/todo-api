class AuthorizeApiRequest
  prepend SimpleCommand

  def initialize(headers = {})
    @headers = headers
  end

  def call
    user
  end

  private

  attr_reader :headers

  def user
    token = http_auth_header

    @user ||= User.find_by_token(token) unless token.nil?
    @user || errors.add(:token, 'Invalid token') && nil
  end

  def http_auth_header
    return headers['Authorization'].split(' ').last if headers['Authorization'].present?

    errors.add(:token, 'Missing token')

    nil
  end
end
