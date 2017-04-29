class ApplicationController < ActionController::Base
  include JSONAPI::ActsAsResourceController

  # Prevent CSRF attacks.
  # TODO: temporarily disabled as was giving error:
  # `NoMethodError (undefined method `flash=' for #<ActionDispatch::Request:0x00000003a05228>)`
  # - investigate.
  # protect_from_forgery with: :null_session
end
