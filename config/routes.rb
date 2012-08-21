Forums::Application.routes.draw do

  root :to => 'forums#index'

  resources :posts
  match 'posts/:id/quote'       => 'posts#quote',  :as => :quote_post
  #match 'posts/:id/:post_count' => 'posts#index',  :as => :view_post
  
  
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

    match 'options' => 'options#index'   , :as => :options

    # forums manager
    match 'forums'              => 'forums#index'   , :as => :forum
    match 'forums/new'          => 'forums#new'     , :as => :new_forum
    match 'forums/create'       => 'forums#create'  , :as => :create_forum
    match 'forums/order'        => 'forums#order'   , :as => :order_forum
    match 'forums/:id/edit'     => 'forums#edit'    , :as => :edit_forum
    match 'forums/:id/update'   => 'forums#update'  , :as => :update_forum
    match 'forums/:id/remove'   => 'forums#remove'  , :as => :remove_forum
    match 'forums/:id/destroy'  => 'forums#destroy' , :as => :destroy_forum
    
    # usergroups manager
    match 'usergroups'              => 'usergroups#index'   , :as => :usergroup
    match 'usergroups/new'          => 'usergroups#new'     , :as => :new_usergroup
    match 'usergroups/create'       => 'usergroups#create'  , :as => :create_usergroup
    match 'usergroups/:id/edit'     => 'usergroups#edit'    , :as => :edit_usergroup
    match 'usergroups/:id/update'   => 'usergroups#update'  , :as => :update_usergroup
    match 'usergroups/:id/remove'   => 'usergroups#remove'  , :as => :remove_usergroup
    match 'usergroups/:id/destroy'  => 'usergroups#destroy' , :as => :destroy_usergroup
    
    
  end
  
end


