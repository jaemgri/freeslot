require "test_helper"

class EventTest < ActiveSupport::TestCase
  def build_event(**attrs)
    Event.new({
      title: "Dinner",
      start_date: Date.new(2026, 10, 5),
      end_date: Date.new(2026, 10, 6),
      start_hour: 18,
      end_hour: 20
    }.merge(attrs))
  end

  test "generates an 8 character slug on create" do
    event = build_event
    event.save!
    assert_match(/\A[a-z0-9]{8}\z/, event.slug)
  end

  test "rejects an end date before the start date" do
    assert_not build_event(end_date: Date.new(2026, 10, 4)).valid?
  end

  test "rejects ranges longer than MAX_DAYS" do
    assert_not build_event(end_date: Date.new(2026, 10, 5) + Event::MAX_DAYS).valid?
  end

  test "rejects an end hour that isn't after the start hour" do
    assert_not build_event(end_hour: 18).valid?
  end

  test "time_rows covers the window in 30 minute steps" do
    assert_equal [ 1080, 1110, 1140, 1170 ], build_event.time_rows
  end

  test "valid_slot? only accepts real cells in the grid" do
    event = build_event
    assert event.valid_slot?(Time.zone.local(2026, 10, 5, 18, 30))
    assert_not event.valid_slot?(Time.zone.local(2026, 10, 5, 20, 0)),  "end hour is exclusive"
    assert_not event.valid_slot?(Time.zone.local(2026, 10, 5, 18, 15)), "not on a slot boundary"
    assert_not event.valid_slot?(Time.zone.local(2026, 10, 7, 18, 0)),  "outside the date range"
  end

  test "best_ranges merges consecutive top slots into one range" do
    t = ->(h, m) { Time.zone.local(2026, 10, 5, h, m) }
    counts = { t.(18, 0).to_i => 1, t.(18, 30).to_i => 2, t.(19, 0).to_i => 2, t.(19, 30).to_i => 1 }

    ranges, top = build_event.best_ranges(counts)

    assert_equal 2, top
    assert_equal [ [ t.(18, 30), t.(19, 30) ] ], ranges
  end
end
