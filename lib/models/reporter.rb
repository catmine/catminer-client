module CatminerClient
  class Reporter
    attr_accessor :rig

    def initialize(rig)
      @initialized = false
      @rig = rig
    end
  
    def register
      @rig = Rig.default
      response = Typhoeus.post SETTINGS['url'] + '/v3/rigs/register', body: { name: @rig.name }

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
        }.to_json,
        initialized: @initialized,
        secret: @rig.secret
      }

      body[:gpus_log] = @rig.gpus.enable.map { |gpu|
        {
          utilization: gpu.utilization,
          power: gpu.power,
          temperature: gpu.temperature,
          fan: gpu.fan,
          memory_used: gpu.memory_used
        }
      }.to_json

      mining_logs = @rig.mining_logs.unreported
      body[:mining_logs] = mining_logs.map { |mining_log|
        {
          line: mining_log.line.force_encoding("ISO-8859-1").encode("UTF-8"),
          line_at: mining_log.created_at
        }
      }.to_json

      unless @initialized
        @initialized = true

        body[:gpus] = @rig.gpus.enable.map { |gpu|
          {
            name: gpu.name,
            uuid: gpu.uuid,
            memory: gpu.memory
          }
        }.to_json
      end

      response = Typhoeus.post SETTINGS['url'] + '/v3/rigs/' + @rig.uuid, body: body

      if response.code == 200
        json = JSON.parse response.body
        mining_at = DateTime.parse json['mining']['mining_at']

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
        loop do
          begin
            Rails.application.executor.wrap do
              if @rig.uuid.present? && @rig.secret.present?
                report
              else
                register
              end
            end
          rescue StandardError
          end

          sleep 10
        end
      end
    end
  end
end