class Availability < ApplicationRecord
  belongs_to :participant
  has_one :event, through: :participant

  validates :slot_at, presence: true, uniqueness: { scope: :participant_id }
  validate :slot_inside_event

  after_commit :refresh_event_viewers

  private

  def slot_inside_event
    return if slot_at.nil? || participant.nil?
    errors.add(:slot_at, "is outside this event") unless participant.event.valid_slot?(slot_at)
  end

  def refresh_event_viewers
    participant&.event&.broadcast_refresh_later
  end
end
