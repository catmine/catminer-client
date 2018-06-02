module CatminerClient
  class Rig
    extend ActiveModel::Naming

    include ActiveModel::Conversion
    include SSHKit::DSL

    def initialize
      setting = Setting.where(parameter: 'first_seen_at').first_or_initialize

      if setting.value.present?
        @first_seen_at = DateTime.parse setting.value
      else
        @first_seen_at = Time.zone.now.localtime
        setting.update value: @first_seen_at
      end

      self.overclock_gpus
    end

    def first_seen_at
      @first_seen_at
    end

    def gpus
      if @gpus_updated_at.blank? || @gpus_updated_at < 10.seconds.ago
        gpus = nil

        run_locally do
          setting = Setting.where(parameter: 'gpus').first_or_initialize
            
          xml = Nokogiri::XML `nvidia-smi -q -x`
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
            setting.update value: @gpus.to_json
          end
        end

        @gpus_updated_at = Time.zone.now
        @gpus = gpus
      end

      @gpus
    end

    def hostname
      hostname = nil

      run_locally do
        as :root do
          setting = Setting.where(parameter: 'hostname').first_or_initialize
          hostname = capture(:cat, '/etc/hostname').strip
          setting.update value: hostname
        end
      end

      hostname
    end

    def hostname=(_hostname)
      run_locally do
        as :root do
          hostname = capture(:cat, '/etc/hostname').strip
          
          execute "sudo hostname #{_hostname}"
          execute "sudo sed -i -e 's/#{hostname}/#{_hostname}/g' /etc/hostname"
          execute "sudo sed -i -e 's/#{hostname}/#{_hostname}/g' /etc/hosts"

          setting = Setting.where(parameter: 'hostname').first_or_initialize
          setting.update value: _hostname
        end
      end
    end

    def overclock_gpus
      setting = Setting.where(parameter: 'overclock_gpus').first_or_initialize
      gpus = self.gpus

      unless setting.persisted?
        run_locally do
          as :root do
            overclock_gpus = Array.new
            i = 0

            gpus.each do |gpu|
              if gpu[:name].include? 'GeForce'
                power = 0
                mem_clock = 150
                gpu_clock = 500

                # power consumption from url: https://en.wikipedia.org/wiki/List_of_Nvidia_graphics_processing_units
                if gpu[:name].include? '1030'
                  power = 30 * 0.75
                elsif gpu[:name].include?  '1050'
                  power = 75 * 0.75
                elsif gpu[:name].include?('1060') || gpu[:name].include?('P106')
                  power = 120 * 0.65
                elsif gpu[:name].include?('1080 Ti') || gpu[:name].include?('P102') || gpu[:name].include?('TITAN')
                  power = 250 * 0.65
                elsif gpu[:name].include?('1070 Ti') || gpu[:name].include?('1080') || gpu[:name].include?('P104')
                  power = 180 * 0.65
                elsif gpu[:name].include? '1070'
                  power = 150 * 0.65
                end

                execute "sudo nvidia-xconfig -a --cool-bits=28 --allow-empty-initial-configuration"
                execute("nvidia-smi -i #{i} -pl #{power}") if power > 0
                execute "nvidia-settings -c :0 -a '[gpu:#{i}]/GPUMemoryTransferRateOffset[3]=#{mem_clock}'"
                execute "nvidia-settings -c :0 -a '[gpu:#{i}]/GPUGraphicsClockOffset[3]=#{gpu_clock}'"

                overclock_gpus << { name: gpu[:name], power: power, mem_clock: mem_clock, gpu_clock: gpu_clock }

                i += 1
              else
                overclock_gpus << { name: gpu[:name], power: 0, mem_clock: 0, gpu_clock: 0 }
              end
            end

            setting.update value: overclock_gpus.to_json
          end
        end
      end

      JSON.parse setting.value
    end

    def overclock_gpus=(_gpu_settings)
      setting = Setting.where(parameter: 'overclock_gpus').first_or_initialize
      gpus = self.gpus

      run_locally do
        as :root do
          overclock_gpus = Array.new
          i = 0

          _gpu_settings.each do |gpu_setting|
            if _gpu_settings['name'].include? 'GeForce'
              power = gpu_setting['power']
              mem_clock = gpu_setting['mem_clock']
              gpu_clock = gpu_setting['gpu_clock']

              execute "sudo nvidia-xconfig -a --cool-bits=28 --allow-empty-initial-configuration"
              execute "nvidia-smi -i #{i} -pl #{power}"
              execute "nvidia-settings -c :0 -a '[gpu:#{i}]/GPUMemoryTransferRateOffset[3]=#{mem_clock}'"
              execute "nvidia-settings -c :0 -a '[gpu:#{i}]/GPUGraphicsClockOffset[3]=#{gpu_clock}'"

              overclock_gpus << { name: _gpu_settings[:name], power: power, mem_clock: mem_clock, gpu_clock: gpu_clock }

              i += 1
            else
              overclock_gpus << { name: _gpu_settings[:name], power: 0, mem_clock: 0, gpu_clock: 0 }
            end
          end

          setting.update value: overclock_gpus.to_json
        end
      end

      JSON.parse setting.value
    end

    def power
      p = 0

      gpus.each do |gpu|
        p += gpu[:power].to_i
      end

      "#{p} W"
    end

    def temperature
      t = 0

      gpus.each do |gpu|
        t += gpu[:temperature].to_i
      end

      "#{t / gpus.count} C"
    end

    def utilization
      u = 0

      gpus.each do |gpu|
        u += gpu[:utilization].to_f
      end

      "#{u / self.gpus.count} %"
    end
  end
end