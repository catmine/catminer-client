class HomeController < ApplicationController
  def index
    @page_title = 'Status'
    @rig = Rig.default
  end
end
