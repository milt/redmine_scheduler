class AdmstaffController < ApplicationController
  unloadable

  def index
    authorize! :index, :admin
  end
end
