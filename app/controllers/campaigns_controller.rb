class CampaignsController < ApplicationController
  before_action :set_campaign, only: [:show, :edit, :update, :destroy]

  def index
    @campaigns = current_user.campaigns
      .where.not(status: :draft)
      .includes(:steps)
      .order(Arel.sql("CASE WHEN status = 'completed' THEN 1 ELSE 0 END, created_at DESC"))
  end

  def show
  end

  def edit
  end

  def destroy
    @campaign.destroy
    redirect_to campaigns_path, notice: "Campagne supprimée."
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
