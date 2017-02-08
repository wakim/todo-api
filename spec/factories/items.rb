FactoryGirl.define do
  factory :item do
    description 'abc'
    name 'name'
  end
end

# == Schema Information
#
# Table name: items
#
#  created_at  :datetime         not null
#  description :string
#  done        :boolean          default(FALSE)
#  id          :integer          not null, primary key
#  name        :string
#  updated_at  :datetime         not null
#  user_id     :integer
#
# Indexes
#
#  index_items_on_user_id  (user_id)
#
