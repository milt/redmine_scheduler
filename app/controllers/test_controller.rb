class TestController < ApplicationController
  unloadable


  def index
  	@issues = Issue.will_paginate :page => params[:page]
  end
end
