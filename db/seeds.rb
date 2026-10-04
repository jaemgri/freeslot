# Rebuilds the demo event with fresh dates each time it runs.
Event.find_by(slug: "demo")&.destroy

event = Event.create!(
  slug: "demo",
  title: "Team dinner 🍜",
  start_date: Date.current,
  end_date: Date.current + 4,
  start_hour: 17,
  end_hour: 23
)

# name => [[day index, from hour, to hour], ...]
schedules = {
  "Aya"   => [ [ 0, 18, 21 ], [ 1, 19, 22 ], [ 3, 17, 20 ] ],
  "Ben"   => [ [ 0, 19, 22 ], [ 2, 18, 21 ], [ 3, 18, 21 ] ],
  "Chloe" => [ [ 0, 18, 20 ], [ 1, 18, 21 ], [ 3, 18, 22 ] ],
  "Dan"   => [ [ 1, 20, 23 ], [ 3, 19, 21 ], [ 4, 17, 20 ] ]
}

schedules.each do |name, blocks|
  participant = event.participants.create!(name: name)

  blocks.each do |day, from, to|
    date = event.dates[day]
    (from * 60...to * 60).step(Event::SLOT_MINUTES) do |minutes|
      participant.availabilities.create!(slot_at: event.slot_for(date, minutes))
    end
  end
end

puts "Seeded demo event at /e/demo"
