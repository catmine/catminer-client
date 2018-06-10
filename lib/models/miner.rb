require 'pty'

module CatminerClient
  class Miner
    attr_accessor :rig
    attr_accessor :thread
    attr_accessor :pid

    def initialize(rig)
      @rig = rig
    end

    def add_log(line)
      Rails.application.executor.wrap do
        begin
          rig = Rig.default
          MiningLog.create rig: rig, line: line
        rescue StandardError => e
          Rails.logger.info 'Miner Error'
        end
      end
    end

    def start(cmd)
      self.stop

      @thread = Thread.new do
        self.add_log '==================== Start Mining ===================='

        begin
          PTY.spawn(cmd) do |stdout, stdin, pid|
            @pid = pid

            begin
              stdout.each do |line|
                self.add_log line
              end
            rescue Errno::EIO
            end
          end
        rescue PTY::ChildExited
        end
      end
    end

    def stop
      if @pid.present?
        system "sudo kill -9 #{@pid}"
        system "sudo kill -9 #{@pid + 1}"

        self.add_log '==================== Stop Mining ===================='
        
        @pid = nil
      end
    end
  end
end