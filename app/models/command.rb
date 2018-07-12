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

class Command < ApplicationRecord
  belongs_to :rig

  validates :command_id, uniqueness: true

  after_commit :execute_cmd, on: :create

  scope :unreported, -> { where(reported: false) }

  def execute_cmd
    unless executed
      self.update! executed: true, executed_at: Time.zone.now
      machine = CatminerClient::Machine.new self.rig

      # Reboot
      if self.code == 1
        machine.reboot
      # Shutdown
      elsif self.code == 2
        machine.shutdown
      # Overclock
      elsif self.code == 3
        gpus = JSON.parse self.args
        i = 0

        self.rig.gpus.enable.each do |gpu|
          gpu.power_limit = gpus[i]['power_limit']
          gpu.gpu_clock = gpus[i]['gpu_clock']
          gpu.mem_clock = gpus[i]['mem_clock']

          gpu.save!

          i += 1
        end

        self.rig.overclock
      end
    end
  end

  def status
    if executed
      2
    else
      0
    end
  end
end
