module CatminerClient
  class Miner
    attr_accessor :rig

    def initialize(rig)
      @rig = rig
    end

    def start(arg)
      @rig.pid = Process.spawn arg
      @rig.save!
    end

    def stop
      system "sudo kill -9 #{@rig.pid}"
      system "sudo kill -9 #{@rig.pid + 1}"
    end
  end
end