class TvveetsController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]
  before_filter :correct_user, only: :destroy

  def create
    @tvveet = current_user.tvveets.build(params[:tvveet])
    if @tvveet.save
      flash[:success] = "Tvveet posted!"
      redirect_to root_path
    else
      @feed_items = []
      render "static_pages/home"
    end
  end

  def destroy
    @tvveet.destroy
    redirect_back_or current_user
  end
  
  private

  def correct_user
    @tvveet = current_user.tvveets.find_by_id(params[:id])
    redirect_to current_user if @tvveet.nil?
  end
end