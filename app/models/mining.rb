# == Schema Information
#
# Table name: minings
#
#  id         :integer          not null, primary key
#  rig_id     :integer
#  code       :integer
#  args       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_minings_on_rig_id  (rig_id)
#

class Mining < ApplicationRecord
  belongs_to :rig

  after_commit :start_mining

  def execute_args_string
    if code == 1
      args = JSON.parse self.args
      miner_path = ''

      if args['miner'] == 'ccminer'
        miner_path = "cd #{Dir.pwd}/vendor/miners/ccminer && ./ccminer"
      elsif args['miner'] == 'claymore'
        miner_path = "cd #{Dir.pwd}/vendor/miners/claymore && ./ethdcrminer64"
      elsif args['miner'] == 'ethminer'
        miner_path = "cd #{Dir.pwd}/vendor/miners/ethminer/bin && ./ethminer"
      elsif args['miner'] == 'ewbf_miner'
        miner_path = "cd #{Dir.pwd}/vendor/miners/ewbf-miner && ./miner"
      end

      "#{miner_path} #{args['args']}"
    else
      ''
    end
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
      execute_args_string
    end
  end
end
