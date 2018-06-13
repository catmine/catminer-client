require_relative '../../lib/models/configurator.rb'

namespace :configurator do
  desc 'bootstrap machines first time'
  task :bootstrap do
    configurator = CatminerClient::Configurator.new
    configurator.machines = ENV['machines'].split(',') if ENV['machines'] != nil
    configurator.user = ENV['user'] if ENV['user'] != nil
    configurator.env = ENV['env'] if ENV['env'] != nil
    configurator.bootstrap
  end

  desc 'Reboot'
  task :reboot do
    configurator = CatminerClient::Configurator.new
    configurator.machines = ENV['machines'].split(',') if ENV['machines'] != nil
    configurator.user = ENV['user'] if ENV['user'] != nil
    configurator.reboot
  end

  desc 'Restart app process'
  task :restart do
    configurator = CatminerClient::Configurator.new
    configurator.machines = ENV['machines'].split(',') if ENV['machines'] != nil
    configurator.user = ENV['user'] if ENV['user'] != nil
    configurator.restart
  end

  desc 'Upgrade lastest code'
  task :update do
    configurator = CatminerClient::Configurator.new
    configurator.machines = ENV['machines'].split(',') if ENV['machines'] != nil
    configurator.user = ENV['user'] if ENV['user'] != nil
    configurator.env = ENV['env'] if ENV['env'] != nil
    configurator.update
  end
end