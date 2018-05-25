namespace :configurator do
  desc 'bootstrap machines first time'
  task :bootstrap do
    configurator = CatminerClient::Configurator.new
    configurator.machines = ENV['machines'].split(',') if ENV['machines'] != nil
    configurator.bootstrap
  end

  desc 'Reboot'
  task :reboot do
    configurator = CatminerClient::Configurator.new
    configurator.machines = ENV['machines'].split(',') if ENV['machines'] != nil
    configurator.reboot
  end

  desc 'Restart app process'
  task :restart do
    configurator = CatminerClient::Configurator.new
    configurator.machines = ENV['machines'].split(',') if ENV['machines'] != nil
    configurator.restart
  end

  desc 'Upgrade lastest code'
  task :update do
    configurator = CatminerClient::Configurator.new
    configurator.machines = ENV['machines'].split(',') if ENV['machines'] != nil
    configurator.update
  end

  desc 'Remove catwork'
  task :remove_catwork do
    configurator = CatminerClient::Configurator.new
    configurator.machines = ENV['machines'].split(',') if ENV['machines'] != nil
    configurator.remove_catwork
  end
end