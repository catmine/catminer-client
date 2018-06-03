class HomeController < ApplicationController
  def index
    @rig = Rig.default
  end

  def logs
    @page_title = 'Logs'
    @mining_logs = Rig.default.mining_logs.order('id DESC').limit(1000)
  end
end
