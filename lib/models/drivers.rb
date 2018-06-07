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
        unless test "[ -f #{Dir.pwd}/vendor/drivers/AMD-APP-SDK.sh ]"
          unless test "[ -f #{Dir.pwd}/vendor/drivers/AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2 ]"
            execute "wget http://cs.wisc.edu/~riccardo/assets/AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2 -P #{Dir.pwd}/vendor/drivers"
          end

          execute "cd #{Dir.pwd}/vendor/drivers && tar xjf AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2"
          execute "mv #{Dir.pwd}/vendor/drivers/AMD-APP-SDK-v3.0.130.136-GA-linux64.sh #{Dir.pwd}/vendor/drivers/AMD-APP-SDK.sh"
          execute "chmod +x #{Dir.pwd}/vendor/drivers/AMD-APP-SDK.sh"
          execute "rm #{Dir.pwd}/vendor/drivers/AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2"
        end
      end
    end

    def amd_pro
      run_locally do
        unless test "[ -d #{Dir.pwd}/vendor/drivers/amdgpu-pro ]"
          unless test "[ -f #{Dir.pwd}/vendor/drivers/amdgpu-pro-17.50-511655.tar.xz ]"
            execute "wget https://www2.ati.com/drivers/linux/ubuntu/amdgpu-pro-17.50-511655.tar.xz --referer=http://support.amd.com -P #{Dir.pwd}/vendor/drivers"
          end

          execute "cd #{Dir.pwd}/vendor/drivers && tar -Jxvf amdgpu-pro-17.50-511655.tar.xz"
          execute "mv #{Dir.pwd}/vendor/drivers/amdgpu-pro-17.50-511655 #{Dir.pwd}/vendor/drivers/amdgpu-pro"
          execute "rm #{Dir.pwd}/vendor/drivers/amdgpu-pro-17.50-511655.tar.xz"
        end
      end
    end

    def cuda
      run_locally do
        unless test "[ -f #{Dir.pwd}/vendor/drivers/cuda.deb ]"
          unless test "[ -f #{Dir.pwd}/vendor/drivers/cuda-repo-ubuntu1604-9-2-local_9.2.88-1_amd64 ]"
            execute "wget https://developer.nvidia.com/compute/cuda/9.2/Prod/local_installers/cuda-repo-ubuntu1604-9-2-local_9.2.88-1_amd64 -P #{Dir.pwd}/vendor/drivers"
          end

          execute "mv #{Dir.pwd}/vendor/drivers/cuda-repo-ubuntu1604-9-2-local_9.2.88-1_amd64 #{Dir.pwd}/vendor/drivers/cuda.deb"
        end
      end
    end
  end
end