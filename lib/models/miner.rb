module CatminerClient
  class Miner
    include SSHKit::DSL

    def initialize
      run_locally do
        test "mkdir #{Dir.pwd}/vendor/miners"
      end
    end

    def all
      self.ccminer
      self.claymore
      self.ethminer
    end

    def ccminer
      run_locally do
        execute 'sudo apt-get install -y build-essential autoconf automake libtool pkg-config libcurl4-gnutls-dev uthash-dev libncursesw5-dev libjansson-dev autotools-dev gcc-5 g++-5'

        test "git clone https://github.com/tpruvot/ccminer #{Dir.pwd}/miners/ccminer"
        execute "cd #{Dir.pwd}/miners/ccminer && git pull"

        execute "cd #{Dir.pwd}/miners/ccminer && ./autogen.sh"
        execute "cd #{Dir.pwd}/miners/ccminer && ./configure"
        execute "cd #{Dir.pwd}/miners/ccminer && make"
      end
    end

    def claymore
      run_locally do
        execute "wget https://github.com/nanopool/Claymore-Dual-Miner/releases/download/v10.0/Claymore.s.Dual.Ethereum.Decred_Siacoin_Lbry_Pascal.AMD.NVIDIA.GPU.Miner.v10.0.-.LINUX.tar.gz -P #{Dir.pwd}/miners"
        test "mkdir #{Dir.pwd}/vendor/miners/claymore"
        execute "tar -xvzf #{Dir.pwd}/miners/Claymore.s.Dual.Ethereum.Decred_Siacoin_Lbry_Pascal.AMD.NVIDIA.GPU.Miner.v10.0.-.LINUX.tar.gz -C #{Dir.pwd}/vendor/miners/claymore"
      end
    end

    def ethminer
      run_locally do
        execute "wget https://github.com/ethereum-mining/ethminer/releases/download/v0.13.0rc7/ethminer-0.13.0rc7-Linux.tar.gz -P #{Dir.pwd}/miners"
        test "mkdir #{Dir.pwd}/vendor/miners/ethminer"
        execute "tar -xvzf #{Dir.pwd}/miners/ethminer-0.13.0rc7-Linux.tar.gz -C #{Dir.pwd}/vendor/miners/ethminer"
      end
    end
  end
end