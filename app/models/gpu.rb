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

class Gpu < ApplicationRecord
  enum brand: [:nvidia, :ati]

  belongs_to :rig

  validates :name, :rig_id, :brand, presence: true
  validates :uuid, uniqueness: true

  scope :enable, -> { where enabled: true }
end
