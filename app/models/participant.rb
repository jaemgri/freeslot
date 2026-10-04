class Participant < ApplicationRecord
  belongs_to :event
  has_many :availabilities, dependent: :destroy

  validates :name, presence: true, length: { maximum: 30 },
                    uniqueness: { scope: :event_id, case_sensitive: false}
end
