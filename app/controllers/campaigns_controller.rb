class CampaignsController < ApplicationController
  def index
    @campaigns = Campaign.all
  end

  def show
    @campaign = Campaign.find(params[:id])
  end

  def edit
    @campaign = Campaign.find(params[:id])
  end

  def update
    @campaign = Campaign.find(params[:id])
    if @campaign.update(campaign_params)
      redirect_to @campaign
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def campaign_params
    params.require(:campaign).permit(:title, :icp, :status, :angles, :channels, :doc_content)
  end
end
