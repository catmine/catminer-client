module CatminerClient
  class Machine
    include SSHKit::DSL

    attr_accessor :rig

    def initialize(rig)
      @rig = rig
    end

    def gpus
      gpus = nil

      run_locally do
        xml = Nokogiri::XML capture('nvidia-smi -q -x')
        gpus = Array.new

        xml.xpath('//gpu').each do |gpu|
          gpus << {
            name: gpu.xpath('//product_name').first.content,
            uuid: gpu.xpath('//uuid').first.content,
            memory: gpu.xpath('//fb_memory_usage').first.xpath('//total').first.content.gsub(/\sMiB/, ''),
            utilization: gpu.xpath('//gpu_util').first.content.gsub(/\s%/, ''),
            power: gpu.xpath('//power_draw').first.content.gsub(/\sW/, ''),
            temperature: gpu.xpath('//gpu_temp').first.content.gsub(/\sC/, ''),
            fan: gpu.xpath('//fan_speed').first.content.gsub(/\s%/, '').gsub('N/A', ''),
            memory_used: gpu.xpath('//fb_memory_usage').first.xpath('//used').first.content.gsub(/\sMiB/, '')
          }
        end
      end

      gpus
    end

    def hostname
      hostname = nil

      run_locally do
        as :root do
          hostname = capture(:cat, '/etc/hostname').strip
        end
      end

      hostname
    end

    def hostname=(_hostname)
      run_locally do
        as :root do
          hostname = capture(:cat, '/etc/hostname').strip
          _hostname = _hostname.strip
          
          if hostname != _hostname
            execute "sudo hostname #{_hostname}"
            execute "sudo sed -i -e 's/#{hostname}/#{_hostname}/g' /etc/hostname"
            execute "sudo sed -i -e 's/#{hostname}/#{_hostname}/g' /etc/hosts"
          end
        end
      end
    end

    def overclock
      i = 0
      @rig.gpus.enable.each do |gpu|
        run_locally do
          as :root do
            if gpu.brand == 'nvidia'
              execute "sudo nvidia-xconfig -a --cool-bits=28 --allow-empty-initial-configuration"
              execute("nvidia-smi -i #{i} -pl #{gpu.power_limit}") if gpu.power_limit.present?
              execute("nvidia-settings -c :0 -a '[gpu:#{i}]/GPUMemoryTransferRateOffset[3]=#{gpu.mem_clock}'") if gpu.mem_clock.present?
              execute("nvidia-settings -c :0 -a '[gpu:#{i}]/GPUGraphicsClockOffset[3]=#{gpu.gpu_clock}'") if gpu.gpu_clock.present?
            end
          end
        end

        i += 1
      end
    end

    def reboot
      `sudo reboot`
    end

    def shutdown
      `sudo shutdown now`
    end
  end
end