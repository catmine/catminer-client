class HomeController < ApplicationController
  def index
    @rig = Rig.default
  end
end
