# == Schema Information
#
# Table name: minings
#
#  id         :integer          not null, primary key
#  rig_id     :integer
#  code       :integer
#  miner      :integer
#  arg        :text
#  mining_at  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_minings_on_rig_id  (rig_id)
#

FactoryBot.define do
  factory :mining do
    rig nil
    code 1
    args "MyText"
  end
end
