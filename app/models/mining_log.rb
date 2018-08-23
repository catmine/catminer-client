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

class MiningLog < ApplicationRecord
  belongs_to :rig

  scope :reported, -> { where(reported: true) }
  scope :unreported, -> { where(reported: false) }

  def log_line
    "[#{I18n.l created_at, format: :long}]: #{line}"
  end
end
