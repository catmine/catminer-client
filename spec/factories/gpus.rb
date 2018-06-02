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

FactoryBot.define do
  factory :gpu do
    name "MyString"
    rig nil
    brand 1
    uuid "MyString"
    memory 1.5
    utilization 1.5
    power 1.5
    temperature 1.5
    fan 1.5
    memory_used 1.5
    power_limit 1.5
    mem_clock 1.5
    gpu_clock 1.5
  end
end
