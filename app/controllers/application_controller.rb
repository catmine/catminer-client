class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :application

  def application
    @page_title = 'CatMiner Client'
  end
end
