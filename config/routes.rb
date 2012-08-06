Forums::Application.routes.draw do

  root :to => 'forums#index'

  resources :posts
  resources :topics
  resources :forums
  resources :sessions
  resources :users

  # account managment
  match 'user/edit' => 'users#edit'       , :as => :edit_current_user
  match 'signup'    => 'users#new'        , :as => :signup
  match 'logout'    => 'sessions#destroy' , :as => :logout
  match 'login'     => 'sessions#new'     , :as => :login

  # admin control panel
  namespace :admincp do
    # admincp home
    root to: "dashboard#index"

    # forums manager
    match 'forums'              => 'forums#index'   , :as => :forum
    match 'forums/new'          => 'forums#new'     , :as => :new_forum
    match 'forums/create'       => 'forums#create'  , :as => :create_forum
    match 'forums/order'        => 'forums#order'   , :as => :order_forum
    match 'forums/edit/:id'     => 'forums#edit'    , :as => :edit_forum
    match 'forums/update/:id'   => 'forums#update'  , :as => :update_forum
    match 'forums/remove/:id'   => 'forums#remove'  , :as => :remove_forum
    match 'forums/destroy/:id'  => 'forums#destroy' , :as => :destroy_forum
  end
end
