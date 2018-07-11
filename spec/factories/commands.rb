# == Schema Information
#
# Table name: commands
#
#  id          :integer          not null, primary key
#  rig_id      :integer
#  command_id  :integer
#  code        :integer
#  args        :string
#  executed    :boolean          default(FALSE)
#  executed_at :datetime
#  reported    :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_commands_on_rig_id  (rig_id)
#

FactoryBot.define do
  factory :command do
    rig nil
    code 1
    args "MyString"
    executed false
    executed_at "2018-07-11 11:20:29"
  end
end
