# == Schema Information
#
# Table name: settings
#
#  id         :integer          not null, primary key
#  parameter  :string
#  value      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Setting < ApplicationRecord
  validates :parameter, uniqueness: true
end
