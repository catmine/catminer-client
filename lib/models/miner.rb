require 'pty'

module CatminerClient
  class Miner
    attr_accessor :rig
    attr_accessor :thread
    attr_accessor :pid

    def initialize(rig)
      @rig = rig
    end

    def start(cmd)
      
      @rig = Rig.default
      self.stop

      @thread = Thread.new do
        Rails.application.reloader.wrap do
          MiningLog.create rig: @rig, line: '==================== Start Mining ===================='

          begin
            PTY.spawn(cmd) do |stdout, stdin, pid|
              @pid = pid

              begin
                stdout.each do |line|
                  MiningLog.create rig: @rig, line: line
                end
              rescue Errno::EIO
              end
            end
          rescue PTY::ChildExited
          end
        end
      end
    end

    def stop
      if @pid.present?
        system "sudo kill -9 #{@pid}"
        system "sudo kill -9 #{@pid + 1}"

        MiningLog.create rig: @rig, line: '==================== Stop Mining ===================='

        @pid = nil
      end
    end
  end
end