class StepsController < ApplicationController
  before_action :set_campaign_and_step

  def show
    @parsed = @step.parse_content
    ordered       = @campaign.steps.order(:day).to_a
    idx           = ordered.index { |s| s.id == @step.id }
    @prev_step    = ordered[idx - 1] if idx > 0
    @next_step    = ordered[idx + 1]
    @total_steps  = ordered.length
    @step_position = idx + 1
    @done_steps   = @campaign.steps.where(status: "done").count
  end

  def edit
    @parsed = @step.parse_content
  end

  def toggle_status
    new_status = @step.status == "done" ? "pending" : "done"
    @step.update!(status: new_status)
    respond_to do |format|
      format.html { redirect_to campaign_step_path(@campaign, @step) }
      format.json { render json: { status: @step.status } }
    end
  end

  def update
    sp = params[:step] || {}
    assembled = Step.assemble_content(
      channel:      sp[:channel].to_s,
      content:      sp[:content_body].to_s,
      instructions: sp[:instructions].to_s
    )

    @step.generated_content = assembled
    @step.status = sp[:status] || @step.status

    if @step.save
      redirect_to campaign_path(@campaign), notice: "Étape modifiée avec succès."
    else
      @parsed = {
        channel:      sp[:channel].to_s,
        content:      sp[:content_body].to_s,
        instructions: sp[:instructions].to_s
      }
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_campaign_and_step
    @campaign = current_user.campaigns.find(params[:campaign_id])
    @step = @campaign.steps.find(params[:id])
  end
end
