class AvailabilitiesController < ApplicationController
  def toggle
    @event = Event.find_by!(slug: params[:id])
    participant = current_participant_for(@event)
    return head :forbidden unless participant

    slot = Time.zone.parse(params[:slot].to_s)
    return head :unprocessable_entity unless slot && @event.valid_slot?(slot)

    existing = participant.availabilities.find_by(slot_at: slot)
    if existing
      existing.destroy
    else
      participant.availabilities.create!(slot_at: slot)
    end

    redirect_to @event
  end
end
