class EventsController < ApplicationController
  before_action :set_event, only: [ :show, :edit, :update, :destroy, :manage ]
  before_action :require_owner, only: [ :edit, :update, :destroy ]

  def new
    @event = Event.new(start_date: Date.current, end_date: Date.current + 6, start_hour: 9, end_hour: 21)
    @recent_events = recent_events
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      remember_ownership(@event)
      redirect_to @event, notice: "your plan's ready. send the link to your friends 👇"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    remember_visit(@event)
    @participant = current_participant_for(@event)
    @counts = @event.counts_by_slot.transform_keys(&:to_i)
    @my_slots = @participant ? @participant.availabilities.pluck(:slot_at).map(&:to_i).to_set : Set.new
    @names = @event.participants.order(:created_at).pluck(:name)
    @best_ranges, @best_count = @event.best_ranges(@counts)
  end

  def edit
  end

  def update
    if @event.update(event_params)
      @event.prune_availabilities!
      @event.broadcast_refresh_later
      redirect_to @event, notice: "plan updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to root_path, notice: "plan deleted"
  end

  # The private link an owner can open on another device to manage the plan there too
  def manage
    if @event.owner_token.present? &&
       ActiveSupport::SecurityUtils.secure_compare(params[:token].to_s, @event.owner_token)
      remember_ownership(@event)
      redirect_to edit_event_path(@event), notice: "you can now manage this plan on this device"
    else
      redirect_to @event, alert: "that manage link isn't valid"
    end
  end

  private

  def set_event
    @event = Event.find_by!(slug: params[:id])
  end

  def require_owner
    redirect_to @event, alert: "only the person who made this plan can change it" unless owner_of?(@event)
  end

  def event_params
    params.expect(event: [ :title, :start_date, :end_date, :start_hour, :end_hour ])
  end

  def recent_events
    slugs = Array(session[:visited])
    events = Event.where(slug: slugs).where(end_date: Date.current..)
                  .includes(:participants).index_by(&:slug)
    slugs.filter_map { |slug| events[slug] }.first(5)
  end
end
