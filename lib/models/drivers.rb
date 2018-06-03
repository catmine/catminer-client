module CatminerClient
  class Drivers
    include SSHKit::DSL

    def initialize
      run_locally do
        test "mkdir #{Dir.pwd}/vendor/drivers"
      end
    end

    def all
      self.amd_app_sdk
      self.amd_pro
      self.cuda
    end

    def amd_app_sdk
      run_locally do
        test "rm #{Dir.pwd}/vendor/drivers/AMD-APP-SDK.sh"

        execute "wget wget http://cs.wisc.edu/~riccardo/assets/AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2 -P #{Dir.pwd}/vendor/drivers"
        execute "tar -xvf #{Dir.pwd}/vendor/drivers/AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2"
        execute "mv #{Dir.pwd}/vendor/drivers/AMD-APP-SDK-v3.0.130.136-GA-linux64.sh #{Dir.pwd}/vendor/drivers/AMD-APP-SDK.sh"
        execute "chmod +x #{Dir.pwd}/vendor/drivers/AMD-APP-SDK.sh"
        execute "rm #{Dir.pwd}/vendor/drivers/AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2"
      end
    end

    def amd_pro
      run_locally do
        test "rm -rf #{Dir.pwd}/vendor/drivers/amdgpu-pro"

        execute "wget https://www2.ati.com/drivers/linux/ubuntu/amdgpu-pro-18.10-572953.tar.xz --referer=http://support.amd.com -P #{Dir.pwd}/vendor/drivers"
        execute "tar -Jxvf #{Dir.pwd}/vendor/drivers/amdgpu-pro-18.10-572953.tar.xz"
        execute "mv #{Dir.pwd}/vendor/drivers/amdgpu-pro-18.10-572953 #{Dir.pwd}/vendor/drivers/amdgpu-pro"
        execute "rm #{Dir.pwd}/vendor/drivers/amdgpu-pro-18.10-572953.tar.xz"
      end
    end

    def cuda
      run_locally do
        test "rm -rf #{Dir.pwd}/vendor/drivers/cuda.run"

        execute "wget https://developer.nvidia.com/compute/cuda/9.2/Prod/local_installers/cuda-repo-ubuntu1604-9-2-local_9.2.88-1_amd64 -P #{Dir.pwd}/vendor/drivers"
        execute "mv #{Dir.pwd}/vendor/drivers/cuda-repo-ubuntu1604-9-2-local_9.2.88-1_amd64 #{Dir.pwd}/vendor/drivers/cuda.run"
      end
    end

    
  end
end