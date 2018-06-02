# == Schema Information
#
# Table name: gpus
#
#  id          :integer          not null, primary key
#  name        :string
#  rig_id      :integer
#  brand       :integer
#  uuid        :string
#  memory      :float
#  utilization :float
#  power       :float
#  temperature :float
#  fan         :float
#  memory_used :float
#  power_limit :float
#  mem_clock   :integer
#  gpu_clock   :integer
#  enabled     :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_gpus_on_rig_id  (rig_id)
#

require 'rails_helper'

RSpec.describe Gpu, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
