class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def current_participant_for(event)
    id = session.dig(:participants, event.slug)
    event.participants.find_by(id: id) if id
  end

  def remember_participant(participant)
    session[:participants] ||= {}
    session[:participants][participant.event.slug] = participant.id
  end
end
