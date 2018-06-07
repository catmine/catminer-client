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

require 'rails_helper'

RSpec.describe MiningLog, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
