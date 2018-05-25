class HomeController < ApplicationController
  def index
    @rig = CatminerClient::Rig.new
  end
end
