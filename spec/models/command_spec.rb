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

require 'rails_helper'

RSpec.describe Command, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
