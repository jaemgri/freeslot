class EventsController < ApplicationController
  def new
    @event = Event.new(
      start_date: Date.current,
      end_date: Date.current + 6,
      start_hour: 9,
      end_hour: 21
    )
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to @event, notice: "Event created! Share the link below with your group."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @event = Event.find_by!(slug: params[:id])
    @participant = current_participant_for(@event)
    @counts = @event.counts_by_slot.transform_keys(&:to_i)
    @my_slots = @participant ? @participant.availabilities.pluck(:slot_at).map(&:to_i).to_set : Set.new
    @names = @event.participants.order(:created_at).pluck(:name)
    @best_ranges, @best_count = @event.best_ranges(@counts)
  end

  private

  def event_params
    params.expect(event: [ :title, :start_date, :end_date, :start_hour, :end_hour ])
  end
end
