class ApplicationController < ActionController::Base
  helper_method :owner_of?
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

  def remember_visit(event)
    visited = Array(session[:visited]) - [ event.slug ]
    session[:visited] = [ event.slug, *visited ].first(20)
  end

  def remember_ownership(event)
    tokens = [ event.owner_token, *owned_tokens ].uniq.first(50)
    cookies.permanent.signed[:owned_plans] = tokens
  end

  def owned_tokens
    Array(cookies.signed[:owned_plans])
  end

  def owner_of?(event)
    event.owner_token.present? && owned_tokens.include?(event.owner_token)
  end
end
