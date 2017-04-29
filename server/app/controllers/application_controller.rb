class ApplicationController < ActionController::Base
  include JSONAPI::ActsAsResourceController

  # Prevent CSRF attacks.
  protect_from_forgery with: :null_session
end
