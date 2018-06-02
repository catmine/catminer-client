class SettingsController < ApplicationController
  def index
    @page_title = 'Settings'
    @rig = CatminerClient::Rig.new
  end

  def save
    @rig = CatminerClient::Rig.new

    @rig.hostname = params[:rig][:hostname]

    p params[:rig][:overclock_gpus].count

    flash[:notice] = 'Your settings have been saved.'
    render 'index'
  end
end
