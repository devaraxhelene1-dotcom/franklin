class StepsController < ApplicationController
  def show
    @campaign = Campaign.find(params[:campaign_id])
    @step = @campaign.steps.find(params[:id])
  end

  def edit
    @campaign = Campaign.find(params[:campaign_id])
    @step = @campaign.steps.find(params[:id])
  end

  def update
    @campaign = Campaign.find(params[:campaign_id])
    @step = @campaign.steps.find(params[:id])
    if @step.update(step_params)
      redirect_to edit_campaign_step_path(@campaign, @step), notice: "Step modifié avec succès"
    else
      render :edit
    end
  end

  private

  def step_params
    params.require(:step).permit(:status)
  end
end
