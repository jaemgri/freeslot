class Event < ApplicationRecord
  SLOT_MINUTES = 30
  MAX_DAYS = 14

  has_many :participants, dependent: :destroy
  has_many :availabilities, through: :participants

  has_secure_token :owner_token

  before_validation :generate_slug, on: :create

  validates :title, presence: true, length: { maximum: 80 }
  validates :start_date, :end_date, :start_hour, :end_hour, presence: true
  validates :start_hour, :end_hour, inclusion: { in: 0..24 }
  validate :ranges_makes_sense

  def to_param = slug

  def dates = (start_date..end_date).to_a

  # Minutes past midnight for each row, e.g., [1080, 110, ...] for 18:00, 18:30
  def time_rows
    (start_hour * 60...end_hour * 60).step(SLOT_MINUTES).to_a
  end

  def slot_for(date, minutes)
    date.in_time_zone.beginning_of_day + minutes.minutes
  end

  def valid_slot?(time)
    dates.include?(time.to_date) && time_rows.include?(time.hour * 60 + time.min)
  end

  # { slot_at => number of people free }, powers the heatmap
  def counts_by_slot
    availabilities.group(:slot_at).count
  end

  # counts: { unix_timestamp => people free }. Returns [[[start, end], ...], top_count]
  def best_ranges(counts)
    top = counts.values.max.to_i
    return [ [], 0 ] if top.zero?

    step = SLOT_MINUTES * 60
    starts = counts.select { |_, n| n == top }.keys.sort
    ranges = starts.slice_when { |a, b| b - a > step }
                   .map { |run| [ Time.zone.at(run.first), Time.zone.at(run.last + step) ] }
    [ ranges, top ]
  end

  # After the dates or hours change, drop picked times that are no longer on the grid
  def prune_availabilities!
    outside = availabilities.reject { |availability| valid_slot?(availability.slot_at) }.map(&:id)
    Availability.where(id: outside).delete_all if outside.any?
  end

  private

  def generate_slug
    return if slug.present?
    loop do
      self.slug = SecureRandom.alphanumeric(8).downcase
      break unless Event.exists?(slug: slug)
    end
  end

  def ranges_makes_sense
    return if [ start_date, end_date, start_hour, end_hour ].any?(&:nil?)

    errors.add(:end_date, "must be on or after the start date") if end_date < start_date
    errors.add(:end_date, "can be at most #{MAX_DAYS} days after the start") if (end_date - start_date).to_i >= MAX_DAYS
    errors.add(:end_hour, "must be after the start hour") if end_hour <= start_hour
  end
end
