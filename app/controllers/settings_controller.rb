class SettingsController < ApplicationController
  def index
    @page_title = 'Settings'
    @rig = Rig.default
  end

  def save
    @rig = Rig.default
    if @rig.update(rig_params)
      flash[:notice] = 'Your settings have been saved.'
    else
      flash[:alert] = 'Error!'
    end

    render 'index'
  end

  def shutdown
    @rig = Rig.default
    machine = CatminerClient::Machine.new @rig
    machine.shutdown
  end

  def reboot
    @rig = Rig.default
    machine = CatminerClient::Machine.new @rig
    machine.reboot
  end

  private
    def rig_params
      params.require(:rig).permit :name, gpus_attributes: [:id, :power_limit, :mem_clock, :gpu_clock]
    end
end
