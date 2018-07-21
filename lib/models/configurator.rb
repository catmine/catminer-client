require_relative '../../lib/models/drivers.rb'
require_relative '../../lib/models/miners.rb'

module CatminerClient
  class Configurator
    include SSHKit::DSL

    attr_accessor :machines
    attr_accessor :user
    attr_accessor :env

    def initialize
      @machines = self.machines_from_config
      @env = 'production'
    end

    def bootstrap
      user = @user
      env = @env

      drivers = CatminerClient::Drivers.new
      miners = CatminerClient::Miners.new

      drivers.all
      miners.all

      on @machines do
        #as user do
          execute "sudo sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers"
          execute "sudo sed -i -e 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash pci=nomsi\"/g' /etc/default/grub"
          execute "sudo sed -i -e 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX=\"text pci=nomsi\"/g' /etc/default/grub"
          execute "sudo sed -i -e 's/#GRUB_TERMINAL=console/GRUB_TERMINAL=console/g' /etc/default/grub"

          execute "sudo update-grub"

          # Install Utilities program
          execute 'sudo apt-get update'
          execute "sudo apt-get install -y htop"

          # Upload client
          test 'mkdir /home/' + user + '/catminer-client'

          test 'rm -rf /home/' + user + '/catminer-client/app'
          test 'rm -rf /home/' + user + '/catminer-client/bin'
          test 'rm -rf /home/' + user + '/catminer-client/config'
          test 'rm -rf /home/' + user + '/catminer-client/db'
          test 'rm -rf /home/' + user + '/catminer-client/lib'
          test 'rm -rf /home/' + user + '/catminer-client/public'
          test 'rm -rf /home/' + user + '/catminer-client/spec'
          test 'rm -rf /home/' + user + '/catminer-client/vendor'
          test 'rm /home/' + user + '/catminer-client/.gitignore'
          test 'rm /home/' + user + '/catminer-client/config.ru'
          test 'rm /home/' + user + '/catminer-client/Gemfile'
          test 'rm /home/' + user + '/catminer-client/Gemfile.lock'
          test 'rm /home/' + user + '/catminer-client/package.json'
          test 'rm /home/' + user + '/catminer-client/Rakefile'

          upload! Dir.pwd + '/app', '/home/' + user + '/catminer-client/app', recursive: true
          upload! Dir.pwd + '/bin', '/home/' + user + '/catminer-client/bin', recursive: true
          upload! Dir.pwd + '/config', '/home/' + user + '/catminer-client/config', recursive: true

          test 'mkdir /home/' + user + '/catminer-client/db'

          upload! Dir.pwd + '/db/migrate', '/home/' + user + '/catminer-client/db/migrate', recursive: true
          upload! Dir.pwd + '/db/schema.rb', '/home/' + user + '/catminer-client/db/schema.rb'
          upload! Dir.pwd + '/db/seeds.rb', '/home/' + user + '/catminer-client/db/seeds.rb'

          upload! Dir.pwd + '/lib', '/home/' + user + '/catminer-client/lib', recursive: true

          test 'mkdir /home/' + user + '/catminer-client/log'

          upload! Dir.pwd + '/public', '/home/' + user + '/catminer-client/public', recursive: true
          upload! Dir.pwd + '/spec', '/home/' + user + '/catminer-client/spec', recursive: true

          test 'mkdir /home/' + user + '/catminer-client/tmp'

          upload! Dir.pwd + '/vendor', '/home/' + user + '/catminer-client/vendor', recursive: true

          upload! Dir.pwd + '/.gitignore', '/home/' + user + '/catminer-client/.gitignore'
          upload! Dir.pwd + '/config.ru', '/home/' + user + '/catminer-client/config.ru'
          upload! Dir.pwd + '/Gemfile', '/home/' + user + '/catminer-client/Gemfile'
          upload! Dir.pwd + '/Gemfile.lock', '/home/' + user + '/catminer-client/Gemfile.lock'
          upload! Dir.pwd + '/package.json', '/home/' + user + '/catminer-client/package.json'
          upload! Dir.pwd + '/Rakefile', '/home/' + user + '/catminer-client/Rakefile'

          # Install Nvidia Driver
          execute 'sudo add-apt-repository ppa:graphics-drivers'
          execute 'sudo apt-get update'
          #execute 'sudo apt-get install -y nvidia-396'
          #execute 'sudo apt-mark hold nvidia-396'

          execute 'sudo dpkg -i /home/' + user + '/catminer-client/vendor/drivers/cuda.deb'
          execute 'sudo apt-key add /var/cuda-repo-9-2-local/7fa2af80.pub'
          execute 'sudo apt-get update'
          execute 'sudo apt-get install -y libboost-all-dev cmake cuda'

          environment = capture :cat, '/etc/environment'

          unless environment.include? 'LD_LIBRARY_PATH'
            execute 'echo \'LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda-9.2/lib64:/usr/local/cuda-9.2/lib64/stubs"\' | sudo tee --append /etc/environment'
            execute 'echo "export PATH=$PATH:/usr/local/cuda-9.2/:/usr/local/cuda-9.2/bin"'
            execute 'source /etc/environment'
          end

          # Install AMD Driver
          execute 'cd /home/' + user + '/catminer-client/vendor/drivers && ./amdgpu-pro/amdgpu-pro-install -y --compute'
          execute 'sudo usermod -a -G video ' + user
          execute 'sudo apt-get install -y rocm-amdgpu-pro clinfo'

          execute "cd /home/" + user + "/catminer-client/vendor/drivers && ./AMD-APP-SDK.sh -- --acceptEULA 'yes' -s"

          # Install Ruby
          unless test 'ruby -v'
            execute 'curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -'
            execute 'curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -'
            execute 'echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list'

            execute 'sudo apt-get update'
            execute 'sudo apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs yarn'

            unless test '[ -f /home/' + user + '/ruby-2.5.0.tar.gz ]'
              execute 'cd /home/' + user + ' && wget http://ftp.ruby-lang.org/pub/ruby/2.5/ruby-2.5.0.tar.gz'
            end

            unless test '[ -d /home/' + user + '/ruby-2.5.0 ]'
              execute 'tar -xzvf /home/' + user + '/ruby-2.5.0.tar.gz'
            end

            execute 'cd /home/' + user + '/ruby-2.5.0 && ./configure'
            execute 'cd /home/' + user + '/ruby-2.5.0 && make'
            execute 'cd /home/' + user + '/ruby-2.5.0 && sudo make install'
          end

          execute 'sudo gem install bundler'

          unless test '[ -f /etc/systemd/system/catminer-client.service ]'
            execute 'echo "[Unit]" | sudo tee --append /etc/systemd/system/catminer-client.service'
            execute 'echo "Description=Catminer Client" | sudo tee --append /etc/systemd/system/catminer-client.service'
            execute 'echo "After=network.target" | sudo tee --append /etc/systemd/system/catminer-client.service'
            execute 'echo "[Service]" | sudo tee --append /etc/systemd/system/catminer-client.service'
            execute 'echo "Type=simple" | sudo tee --append /etc/systemd/system/catminer-client.service'
            execute 'echo "User=root" | sudo tee --append /etc/systemd/system/catminer-client.service'
            execute 'echo "Group=root" | sudo tee --append /etc/systemd/system/catminer-client.service'
            execute 'echo "WorkingDirectory=/home/' + user + '/catminer-client" | sudo tee --append /etc/systemd/system/catminer-client.service'
            execute 'echo "Environment=RAILS_ENV='+ env + '" | sudo tee --append /etc/systemd/system/catminer-client.service'
            execute 'echo "Environment=RAILS_SERVE_STATIC_FILES=true" | sudo tee --append /etc/systemd/system/catminer-client.service'
            execute 'echo "ExecStart=/usr/local/bin/puma -p 80" | sudo tee --append /etc/systemd/system/catminer-client.service'
            execute 'echo "Restart=always" | sudo tee --append /etc/systemd/system/catminer-client.service'
            execute 'echo "[Install]" | sudo tee --append /etc/systemd/system/catminer-client.service'
            execute 'echo "WantedBy=multi-user.target" | sudo tee --append /etc/systemd/system/catminer-client.service'
          end

          execute 'cd /home/' + user + '/catminer-client && sudo bundle install --without development test'
          test 'cd /home/' + user + '/catminer-client && RAILS_ENV='+ env + ' rake db:create'
          execute 'cd /home/' + user + '/catminer-client && RAILS_ENV='+ env + ' rake db:migrate'
          execute 'cd /home/' + user + '/catminer-client && RAILS_ENV='+ env + ' rake assets:precompile'

          test 'sudo service catminer-client stop'
          execute 'sudo service catminer-client start'
          execute 'sudo systemctl enable catminer-client'
        #end

        as 'root' do
          execute 'reboot'
        end
      end
    end

    def reboot
      on @machines do
        as 'root' do
          execute "reboot"
        end
      end
    end

    def machines_from_config
      if File.exist? Dir.pwd + '/machines.json'
        file = File.read Dir.pwd + '/machines.json'
        json = JSON.parse file

        user = json['user'] || 'ubuntu'
        keys = json['keys'] || '~/.ssh/id_rsa.pub'
        auth_methods = json['auth_methods'] || ['publickey']

        SSHKit::Backend::Netssh.configure do |ssh|
          ssh.ssh_options = {
            user: user,
            keys: keys,
            auth_methods: auth_methods
          }
        end

        @user = user

        json['ips']
      else
        Array.new
      end
    end

    def start
      on @machines do
        as 'root' do
          execute 'sudo service catminer-client start'
        end
      end
    end

    def stop
      on @machines do
        as 'root' do
          execute 'sudo service catminer-client start'
        end
      end
    end

    def restart
      on @machines do
        as 'root' do
          execute 'sudo service catminer-client restart'
        end
      end
    end

    def update
      user = @user
      env = @env

      on @machines do
        #as user do
          execute 'sudo service catminer-client stop'

          test 'mkdir /home/' + user + '/catminer-client'

          test 'rm -rf /home/' + user + '/catminer-client/app'
          test 'rm -rf /home/' + user + '/catminer-client/bin'
          test 'rm -rf /home/' + user + '/catminer-client/config'
          test 'rm -rf /home/' + user + '/catminer-client/db/migrate'
          test 'rm /home/' + user + '/catminer-client/db/schema.rb'
          test 'rm /home/' + user + '/catminer-client/db/seeds.rb'
          test 'rm -rf /home/' + user + '/catminer-client/lib'
          test 'rm -rf /home/' + user + '/catminer-client/public'
          test 'rm -rf /home/' + user + '/catminer-client/spec'
          test 'rm /home/' + user + '/catminer-client/.gitignore'
          test 'rm /home/' + user + '/catminer-client/config.ru'
          test 'rm /home/' + user + '/catminer-client/Gemfile'
          test 'rm /home/' + user + '/catminer-client/Gemfile.lock'
          test 'rm /home/' + user + '/catminer-client/package.json'
          test 'rm /home/' + user + '/catminer-client/Rakefile'

          upload! Dir.pwd + '/app', '/home/' + user + '/catminer-client/app', recursive: true
          upload! Dir.pwd + '/bin', '/home/' + user + '/catminer-client/bin', recursive: true
          upload! Dir.pwd + '/config', '/home/' + user + '/catminer-client/config', recursive: true

          test 'mkdir /home/' + user + '/catminer-client/db'

          upload! Dir.pwd + '/db/migrate', '/home/' + user + '/catminer-client/db/migrate', recursive: true
          upload! Dir.pwd + '/db/schema.rb', '/home/' + user + '/catminer-client/db/schema.rb'
          upload! Dir.pwd + '/db/seeds.rb', '/home/' + user + '/catminer-client/db/seeds.rb'

          upload! Dir.pwd + '/lib', '/home/' + user + '/catminer-client/lib', recursive: true

          test 'mkdir /home/' + user + '/catminer-client/log'

          upload! Dir.pwd + '/public', '/home/' + user + '/catminer-client/public', recursive: true
          upload! Dir.pwd + '/spec', '/home/' + user + '/catminer-client/spec', recursive: true

          test 'mkdir /home/' + user + '/catminer-client/tmp'

          test 'mkdir /home/' + user + '/catminer-client/vendor'
          test 'rm -rf /home/' + user + '/catminer-client/vendor/miners'

          upload! Dir.pwd + '/vendor/miners', '/home/' + user + '/catminer-client/vendor/miners', recursive: true

          upload! Dir.pwd + '/.gitignore', '/home/' + user + '/catminer-client/.gitignore'
          upload! Dir.pwd + '/config.ru', '/home/' + user + '/catminer-client/config.ru'
          upload! Dir.pwd + '/Gemfile', '/home/' + user + '/catminer-client/Gemfile'
          upload! Dir.pwd + '/Gemfile.lock', '/home/' + user + '/catminer-client/Gemfile.lock'
          upload! Dir.pwd + '/package.json', '/home/' + user + '/catminer-client/package.json'
          upload! Dir.pwd + '/Rakefile', '/home/' + user + '/catminer-client/Rakefile'

          execute 'cd /home/' + user + '/catminer-client && sudo bundle install --without development test'
          execute 'cd /home/' + user + '/catminer-client && RAILS_ENV='+ env + ' rake db:migrate'
          execute 'cd /home/' + user + '/catminer-client && RAILS_ENV='+ env + ' rake assets:precompile'

          execute 'sudo service catminer-client start'
        #end
      end
    end
  end
end