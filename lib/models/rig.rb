module CatminerClient
  class Rig
    include SSHKit::DSL

    def initialize
      setting = Setting.where(parameter: 'first_seen_at').first_or_initialize

      if setting.value.present?
        @first_seen_at = DateTime.parse setting.value
      else
        @first_seen_at = Time.zone.now
        setting.update value: @first_seen_at
      end
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
          
          execute "hostname #{_hostname}"
          execute "sudo sed -i -e 's/#{hostname}/#{_hostname}/g' /etc/hostname"
          execute "sudo sed -i -e 's/#{hostname}/#{_hostname}/g' /etc/hosts"

          setting = Setting.where(parameter: 'hostname').first_or_initialize
          setting.update value: _hostname
        end
      end
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

    def first_seen_at
      @first_seen_at
    end

    def utilization
      u = 0

      gpus.each do |gpu|
        u += gpu[:utilization].to_f
      end

      "#{u / self.gpus.count} %"
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
  end
end