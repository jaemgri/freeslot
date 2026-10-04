class ParticipantsController < ApplicationController
  def create
    @event = Event.find_by!(slug: params[:event_id])
    name = params.expect(participant: [ :name ])[:name].to_s.strip

    participant = @event.participants.where("LOWER(name) = ?", name.downcase).first ||
                  @event.participants.create(name: name)

    if participant.persisted?
      remember_participant(participant)
      redirect_to @event
    else
      redirect_to @event, alert: participant.errors.full_messages.to_sentence
    end
  end
end
