# == Schema Information
#
# Table name: rigs
#
#  id         :integer          not null, primary key
#  name       :string
#  uuid       :string
#  secret     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :rig do
    name "MyString"
    uuid "MyString"
    secret "MyString"
  end
end
