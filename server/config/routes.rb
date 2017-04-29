Rails.application.routes.draw do
  jsonapi_resources :items
  jsonapi_resources :events
end
