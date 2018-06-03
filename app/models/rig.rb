# == Schema Information
#
# Table name: rigs
#
#  id         :integer          not null, primary key
#  name       :string
#  uuid       :string
#  secret     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Rig < ApplicationRecord
  has_many :gpus, inverse_of: :rig
  has_many :mining_logs
  has_many :minings

  accepts_nested_attributes_for :gpus

  validates :name, :uuid, :secret, presence: true

  after_create :set_default_overclock
  after_commit :change_hostname
  after_commit :overclock

  def self.default
    if Rig.all.count == 0
      rig = Rig.create name: `hostname`, uuid: SecureRandom.uuid, secret: SecureRandom.urlsafe_base64(nil, false)
      
      machine = CatminerClient::Machine.new(rig)
      
      rig.update_gpus
      rig.set_default_overclock
    else
      rig = Rig.first
      rig.update_gpus
    end

    rig
  end

  def change_hostname
    machine = CatminerClient::Machine.new(self)
    machine.hostname = self.name
  end

  def overclock
    machine = CatminerClient::Machine.new(self)
    machine.overclock
  end

  def power
    if self.gpus.exists?
      p = 0

      self.gpus.each do |gpu|
        p += gpu.power
      end

      "#{p} W"
    else
      'N/A'
    end
  end

  def set_default_overclock
    self.gpus.each do |gpu|

      if gpu.brand == 'nvidia'
        power_limit = 0
        mem_clock = 150
        gpu_clock = 500

        # power consumption from url: https://en.wikipedia.org/wiki/List_of_Nvidia_graphics_processing_units
        if gpu.name.include? '1030'
          power_limit = 30 * 0.75
        elsif gpu.name.include?  '1050'
          power_limit = 75 * 0.75
        elsif gpu.name.include?('1060') || gpu.name.include?('P106')
          power_limit = 120 * 0.65
        elsif gpu.name.include?('1080 Ti') || gpu.name.include?('P102') || gpu.name.include?('TITAN')
          power_limit = 250 * 0.65
        elsif gpu.name.include?('1070 Ti') || gpu.name.include?('1080') || gpu.name.include?('P104')
          power_limit = 180 * 0.65
        elsif gpu.name.include? '1070'
          power_limit = 150 * 0.65
        end

        gpu.power_limit = power_limit
        gpu.mem_clock = mem_clock
        gpu.gpu_clock = gpu_clock
      end
    end
  end

  def start_mining
    $miner ||= CatminerClient::Miner.new(Rig.default)
    mining = self.minings.last

    if mining.present?
      if mining.code == 0
        $miner.stop
      elsif mining.code == 1
        $miner.start mining.execute_cmd
      end
    end
  end

  def stop_mining
    self.minings.create code: 0
    self.start_mining
  end

  def temperature
    if self.gpus.exists?
      t = 0

      self.gpus.each do |gpu|
        t += gpu.temperature
      end

      "#{t / gpus.count} C"
    else
      'N/A'
    end
  end

  def update_gpus
    machine = CatminerClient::Machine.new(self)
    gpus_status = machine.gpus

    gpus_status.each do |gpu_status|
      gpu = self.gpus.where(uuid: gpu_status[:uuid]).first_or_initialize
      gpu.name = gpu_status[:name]

      if gpu_status[:name].include? 'GeForce'
        gpu.brand = 0
      else
        gpu.brand = 1
      end

      gpu.memory = gpu_status[:memory]
      gpu.utilization = gpu_status[:utilization]
      gpu.power = gpu_status[:power]
      gpu.temperature = gpu_status[:temperature]
      gpu.fan = gpu_status[:fan]
      gpu.memory_used = gpu_status[:memory_used]
      gpu.enabled = true

      gpu.save!
    end

    unable_gpus = gpus_status.map{ |gpu_status| "uuid != '#{gpu_status[:uuid]}'" }.join(' and ')
    self.gpus.where(unable_gpus).update_all(enabled: false)
  end

  def utilization
    if self.gpus.exists?
      u = 0

      self.gpus.each do |gpu|
        u += gpu.utilization
      end

      "#{u / self.gpus.count} %"
    else
      'N/A'
    end
  end
end
