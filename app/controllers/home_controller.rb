class HomeController < ApplicationController
  def index
    @page_title = 'Status'
    @rig = Rig.default
    @mining = @rig.minings.last
  end
end
