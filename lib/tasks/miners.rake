require_relative '../../lib/models/miner.rb'

namespace :miners do
  desc 'Download & Compile All miner'
  task :all do
    miner = CatminerClient::Miner.new
    miner.all
  end

  desc 'CCMiner - Download & Compile miner'
  task :ccminer do
    miner = CatminerClient::Miner.new
    miner.ccminer
  end

  desc 'EthMiner - Download miner'
  task :ethminer do
    miner = CatminerClient::Miner.new
    miner.ethminer
  end
end