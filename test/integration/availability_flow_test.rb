require "test_helper"

class AvailabilityFlowTest < ActionDispatch::IntegrationTest
  setup do
    @event = Event.create!(title: "Dinner", start_date: Date.new(2026, 10, 5),
                           end_date: Date.new(2026, 10, 6), start_hour: 18, end_hour: 20)
    @slot = Time.zone.local(2026, 10, 5, 18, 30)
  end

  test "creating an event redirects to its share page" do
    post events_path, params: { event: { title: "Karaoke", start_date: "2026-10-05",
                                         end_date: "2026-10-06", start_hour: 18, end_hour: 22 } }
    assert_redirected_to event_path(Event.last)
  end

  test "can't change slots without joining first" do
    post slots_event_path(@event), params: { slots: [ @slot.iso8601 ], available: true }, as: :json
    assert_response :forbidden
  end

  test "a participant can add and remove slots" do
    post event_participants_path(@event), params: { participant: { name: "Aya" } }
    aya = @event.participants.find_by!(name: "Aya")

    post slots_event_path(@event), params: { slots: [ @slot.iso8601 ], available: true }, as: :json
    assert_response :no_content
    assert_equal [ @slot ], aya.availabilities.pluck(:slot_at)

    post slots_event_path(@event), params: { slots: [ @slot.iso8601 ], available: false }, as: :json
    assert_empty aya.availabilities.reload
  end

  test "slots outside the event are ignored" do
    post event_participants_path(@event), params: { participant: { name: "Aya" } }
    post slots_event_path(@event), params: { slots: [ (@slot + 1.year).iso8601, "nonsense" ], available: true }, as: :json

    assert_response :no_content
    assert_equal 0, Availability.count
  end

  test "rejoining with the same name on another device reuses the participant" do
    post event_participants_path(@event), params: { participant: { name: "Aya" } }
    reset! # fresh session, like opening the link on a phone
    post event_participants_path(@event), params: { participant: { name: "aya" } }

    assert_equal 1, @event.participants.count
  end
    test "the creator can edit and delete their plan" do
    post events_path, params: { event: { title: "Karaoke", start_date: "2026-10-05",
                                         end_date: "2026-10-06", start_hour: 18, end_hour: 22 } }
    event = Event.last

    patch event_path(event), params: { event: { title: "Karaoke night" } }
    assert_redirected_to event_path(event)
    assert_equal "Karaoke night", event.reload.title

    delete event_path(event)
    assert_redirected_to root_path
    assert_not Event.exists?(event.id)
  end

  test "other people can't edit or delete someone else's plan" do
    patch event_path(@event), params: { event: { title: "Hijacked" } }
    assert_redirected_to event_path(@event)
    assert_equal "Dinner", @event.reload.title

    delete event_path(@event)
    assert Event.exists?(@event.id)
  end

  test "the manage link makes another device an owner" do
    get manage_event_path(@event, token: @event.owner_token)
    assert_redirected_to edit_event_path(@event)

    patch event_path(@event), params: { event: { title: "Dinner v2" } }
    assert_equal "Dinner v2", @event.reload.title
  end

  test "shortening a plan removes picked times outside the new range" do
    get manage_event_path(@event, token: @event.owner_token)
    post event_participants_path(@event), params: { participant: { name: "Aya" } }
    post slots_event_path(@event), params: { slots: [ Time.zone.local(2026, 10, 6, 18, 0).iso8601 ], available: true }, as: :json

    patch event_path(@event), params: { event: { end_date: "2026-10-05" } }
    assert_equal 0, Availability.count
  end
end
