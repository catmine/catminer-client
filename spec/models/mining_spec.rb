# == Schema Information
#
# Table name: minings
#
#  id         :integer          not null, primary key
#  rig_id     :integer
#  code       :integer
#  miner      :integer
#  arg        :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_minings_on_rig_id  (rig_id)
#

require 'rails_helper'

RSpec.describe Mining, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
