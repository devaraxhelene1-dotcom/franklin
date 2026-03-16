class CampaignsController < ApplicationController
  before_action :set_campaign, only: [:show, :edit, :update]

  def index
    @campaigns = current_user.campaigns.where.not(status: :draft).includes(:steps)
  end

  def show
  end

  def edit
  end

  def update
    if @campaign.update(campaign_params)
      respond_to do |format|
        format.html { redirect_to @campaign }
        format.json { render json: { status: @campaign.status } }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { error: "Update failed" }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_campaign
    @campaign = current_user.campaigns.includes(:chat, steps: { image_attachment: :blob }).find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(:title, :icp, :status, :angles, :channels, :doc_content)
  end
end
