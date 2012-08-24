Forums::Application.routes.draw do

  root :to => 'forums#index'

  # post
  resources :posts
  match 'posts/:id/quote' => 'posts#quote',  :as => :quote_post
  #match 'post/new(?topic_id=:topic_id)(quote_post=:post_id)' => "posts#new", :as => :new_post
  
  
  ## forums
  #match 'forums'      => 'forums#index' , :as => :forum
  match 'forums/:id'  => 'forums#show'  , :as => :forum
  
  # Topics
  resources :topics
  match 'topics/manage'         => 'topics#manage', :as => :manage_topics, :via => [:post]
  match 'topics/manage/move'    => 'topics#move',   :as => :move_topics,   :via => [:post]
  match 'topics/manage/merge'   => 'topics#merge',  :as => :merge_topics,  :via => [:post]
  match 'topics/manage/delete'  => 'topics#delete', :as => :delete_topics, :via => [:post]


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


