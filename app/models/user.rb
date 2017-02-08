class User < ApplicationRecord
  has_secure_password

  validates_presence_of :email, :password
  has_many :items
end

# == Schema Information
#
# Table name: users
#
#  created_at      :datetime         not null
#  email           :string
#  id              :integer          not null, primary key
#  name            :string
#  password_digest :string
#  token           :string
#  updated_at      :datetime         not null
#
