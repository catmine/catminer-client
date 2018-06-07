require_relative '../../lib/models/machine.rb'
require_relative '../../lib/models/miner.rb'
require_relative '../../lib/models/reporter.rb'

SETTINGS = YAML.load_file("#{::Rails.root}/config/settings.yml")[::Rails.env]
