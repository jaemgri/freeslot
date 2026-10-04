class Availability < ApplicationRecord
  belongs_to :participant
  has_one :event, through: :participant

  validates :slot_at, presence: true, uniqueness: { scope: :participant_id }
  validate :slot_inside_event

  private

  def slot_inside_event
    return if slot_at.nil? || participant.nil?
    errors.add(:slot_at, "is outside this event") unless participant.event.valid_slot?(slot_at)
  end
end
