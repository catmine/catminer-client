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

class Mining < ApplicationRecord
  enum miner: { ccminer: 0, claymore: 1, ethminer: 2, ewbf_miner: 3 }

  belongs_to :rig

  before_commit :set_default_mining_at
  after_commit :start_mining

  def execute_cmd
    if code == 1
      miner_path = ''

      if self.miner == 'ccminer'
        miner_path = "cd #{Dir.pwd}/vendor/miners/ccminer && ./ccminer"
      elsif self.miner == 'claymore'
        miner_path = "cd #{Dir.pwd}/vendor/miners/claymore && ./ethdcrminer64"
      elsif self.miner == 'ethminer'
        miner_path = "cd #{Dir.pwd}/vendor/miners/ethminer/bin && ./ethminer"
      elsif self.miner == 'ewbf_miner'
        miner_path = "cd #{Dir.pwd}/vendor/miners/ewbf-miner && ./miner"
      end

      "#{miner_path} #{self.arg.gsub('$NAME', self.rig.name)}"
    else
      ''
    end
  end

  def set_default_mining_at
    self.mining_at = Time.zone.now if self.mining_at.blank?
  end

  def start_mining
    self.rig.start_mining
  end

  def to_s
    self.to_string
  end

  def to_string
    if code == 0
      'Stop Mining'
    else
      execute_cmd
    end
  end
end
