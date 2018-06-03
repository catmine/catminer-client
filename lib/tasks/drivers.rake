require_relative '../../lib/models/drivers.rb'

namespace :drivers do
  desc 'Download all drivers'
  task :all do
    drivers = CatminerClient::Drivers.new
    drivers.all
  end

  desc 'Download AMD SDK App'
  task :amd_app_sdk do
    drivers = CatminerClient::Drivers.new
    drivers.amd_app_sdk
  end

  desc 'Download AMD Pro'
  task :amd_pro do
    drivers = CatminerClient::Drivers.new
    drivers.amd_pro
  end

  desc 'Download CUDA'
  task :cuda do
    drivers = CatminerClient::Drivers.new
    drivers.cuda
  end
end