class Usergroup < ActiveRecord::Base
  include Bitfields

  belongs_to :users

  attr_accessible :description, :title, :usertitle, :open_tag, :close_tag, :forum_permissions,
                  # permission attributes
                  :can_view_forum, :can_view_threads, :can_view_others_threads, :can_post_threads, 
                  :can_reply_to_own_threads, :can_reply_to_others_threads, :can_edit_own_posts, 
                  :can_delete_own_posts, :can_delete_own_threads, :can_open_close_own_threads, 
                  :can_move_own_threads, :can_rate_threads, :follow_forum_moderation_rules, 
                  :can_tag_own_threads, :can_tag_others_threads, :can_delete_tags_own_threads, 
                  :can_create_tags

  # define the usergroup options here using bitfields
  bitfield :forum_permissions, 
    # Forum Viewing Permissions
    1       => :can_view_forum,
    2       => :can_view_threads, 
    8       => :can_view_others_threads,
    # Post / Thread Permissions
    16      => :can_post_threads,
    32      => :can_reply_to_own_threads,
    64      => :can_reply_to_others_threads,
    128     => :can_edit_own_posts,
    256     => :can_delete_own_posts,
    512     => :can_delete_own_threads,
    1024    => :can_open_close_own_threads,
    2048    => :can_move_own_threads,
    4096    => :can_rate_threads,
    8192    => :follow_forum_moderation_rules,
    16384   => :can_tag_own_threads,
    32768   => :can_tag_others_threads,
    65536   => :can_delete_tags_own_threads,
    131072  => :can_create_tags

end
