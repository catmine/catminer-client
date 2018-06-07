# == Schema Information
#
# Table name: mining_logs
#
#  id         :integer          not null, primary key
#  rig_id     :integer
#  line       :text
#  reported   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_mining_logs_on_rig_id  (rig_id)
#

FactoryBot.define do
  factory :mining_log do
    rig nil
    line "MyText"
  end
end
