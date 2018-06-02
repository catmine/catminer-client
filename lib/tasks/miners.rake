require_relative '../../lib/models/miners.rb'

namespace :miners do
  desc 'Download & Compile All miner'
  task :all do
    miner = CatminerClient::Miners.new
    miner.all
  end

  desc 'CCMiner - Download & Compile miner'
  task :ccminer do
    miner = CatminerClient::Miners.new
    miner.ccminer
  end

  desc 'Claymore - Download miner'
  task :claymore do
    miner = CatminerClient::Miners.new
    miner.claymore
  end

  desc 'EthMiner - Download miner'
  task :ethminer do
    miner = CatminerClient::Miners.new
    miner.ethminer
  end

  desc 'EwbfMiner - Download miner'
  task :ewbf_miner do
    miner = CatminerClient::Miners.new
    miner.ewbf_miner
  end
end