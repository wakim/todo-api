require 'bcrypt'

FactoryGirl.define do
  factory :user do
    email 'a@a.com'
    name 'a'
    password 'secret'
    password_digest BCrypt::Password.create('secret')
    token 'abc'
  end
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
