YellowBrickRoad::Engine.routes.draw do
  root :to => 'closure_compiler#index'
end

Rails.application.routes.draw do
  if Rails.env.development?
    mount YellowBrickRoad::Engine => '/_ybr'
  end
end
