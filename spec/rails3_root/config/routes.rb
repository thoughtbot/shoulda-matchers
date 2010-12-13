Rails.application.routes.draw do |map|
  map.resources :users, :has_many => :posts
  map.resources :posts
end
