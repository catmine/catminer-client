namespace :miners do
  desc 'CCMiner - Download & Compile miner'
  task :ccminer do
    run_locally do
      execute 'sudo apt-get install -y build-essential autoconf automake libtool pkg-config libcurl4-gnutls-dev uthash-dev libncursesw5-dev libjansson-dev autotools-dev gcc-5 g++-5'

      within Dir.pwd + '/vendor/miners' do
        test 'git clone https://github.com/tpruvot/ccminer miners/ccminer'
        execute 'cd miners/ccminer && git pull'
      end

      within Dir.pwd + '/vendor/miners/ccminer' do

        execute "cd #{Dir.pwd}/miners/ccminer && ./autogen.sh"
        execute "cd #{Dir.pwd}/miners/ccminer && ./configure"
        execute "cd #{Dir.pwd}/miners/ccminer && make"
      end
    end
  end

  desc 'EthMiner - Download miner'
  task :ethminer do
    run_locally do
      within Dir.pwd + '/vendor/vendor/miners' do
        execute "wget https://github.com/ethereum-mining/ethminer/releases/download/v0.13.0rc7/ethminer-0.13.0rc7-Linux.tar.gz -P #{Dir.pwd}/miners"
        test "mkdir #{Dir.pwd}/vendor/miners/ethminer"
        execute "tar -xvzf #{Dir.pwd}/miners/ethminer-0.13.0rc7-Linux.tar.gz -C #{Dir.pwd}/vendor/miners/ethminer"
      end
    end
  end
end