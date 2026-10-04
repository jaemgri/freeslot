class AvailabilitiesController < ApplicationController
  MAX_SLOTS = 1000

  def update
    @event = Event.find_by!(slug: params[:id])
    participant = current_participant_for(@event)
    return head :forbidden unless participant

    slots = Array(params[:slots]).first(MAX_SLOTS).filter_map { |s| parse_slot(s) }.uniq

    if ActiveModel::Type::Boolean.new.cast(params[:available])
      rows = slots.map { |slot| { participant_id: participant.id, slot_at: slot } }
      Availability.insert_all(rows, unique_by: [ :participant_id, :slot_at ]) if rows.any?
    else
      participant.availabilities.where(slot_at: slots).delete_all
    end

    @event.broadcast_refresh_later
    head :no_content
  end

  private

  def parse_slot(value)
    time = Time.zone.parse(value.to_s)
    time if time && @event.valid_slot?(time)
  rescue ArgumentError
    nil
  end
end
