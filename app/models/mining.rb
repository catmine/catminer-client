# == Schema Information
#
# Table name: minings
#
#  id         :integer          not null, primary key
#  rig_id     :integer
#  code       :integer
#  args       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_minings_on_rig_id  (rig_id)
#

class Mining < ApplicationRecord
  belongs_to :rig
end
