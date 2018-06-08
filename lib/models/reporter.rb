module CatminerClient
  class Reporter
    attr_accessor :rig

    def initialize(rig)
      @initialized = false
      @rig = rig
    end
  
    def register
      @rig = Rig.default
      response = Typhoeus.post SETTINGS['url'] + '/v3/rigs/register', body: { name: HOSTNAME }

      if response.code == 200
        json = JSON.parse response.body

        if json['code'] == 1
          @rig.uuid = json['args']['uuid']
          @rig.secret = json['args']['secret']
          @rig.save!

          true
        else
          false
        end
      else
        false
      end
    end

    def report
      @rig = Rig.default
      mining = @rig.minings.last

      body = {
          mining: {
            code: mining.code,
            miner: mining.miner,
            arg: mining.arg,
            mining_at: mining.mining_at
          },
          initialized: @initialized,
          secret: @rig.secret
        }

      body[:gpus_log] = Array.new
      @rig.gpus.enable.each do |gpu|
        body[:gpus_log] << {
            utilization: gpu.utilization,
            power: gpu.power,
            temperature: gpu.temperature,
            fan: gpu.fan,
            memory_used: gpu.memory_used
          }
      end

      body[:mining_logs] = Array.new
      mining_logs = @rig.mining_logs.unreported
      mining_logs.each do |mining_log|
        body[:mining_logs] << {
          line: mining_log.line,
          line_at: mining_log.created_at
        }
      end

      unless @initialized
        @initialized = true
        body[:gpus] = Array.new

        @rig.gpus.enable.each do |gpu|
          body[:gpus] << {
              name: gpu.name,
              uuid: gpu.uuid,
              memory: gpu.memory
            }
        end
      end

      response = Typhoeus.post SETTINGS['url'] + '/v3/rigs/' + @rig.uuid, body: body

      if response.code == 200
        json = JSON.parse response.body
        mining_at = DateTime.parse(json['mining']['mining_at'])

        if mining_at != mining.mining_at
          if mining_at > mining.mining_at
            @rig.minings.create! code: json['mining']['code'], miner: json['mining']['miner'], arg: json['mining']['arg'], mining_at: mining_at
          end
        end

        mining_logs.update_all reported: true
      end
    end

    def start_report
      @thread = Thread.new do
        Rails.application.reloader.wrap do
          loop do
            begin
              report
            rescue StandardError
            end

            sleep 20
          end
        end
      end
    end
  end
end