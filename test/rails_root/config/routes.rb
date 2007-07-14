ActionController::Routing::Routes.draw do |map|
  map.resources :users do |user|
    user.resources :posts
  end
end
