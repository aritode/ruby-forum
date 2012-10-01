class ForumsController < ApplicationController
  # /forums
  def index
    @forumbits  = build_forum_index
    @lightbulbs = fetch_unread_forums
    @lastposts  = fetch_lastposts @forumbits.map(&:last_post_id).flatten.delete_if {|x| x == 0 }
  end

  # /forums/:id
  def show
    perpage = 25
    page    = params[:page]      || 1
    days    = params[:daysprune] || "-1"
    order   = params[:order]     || "desc" 
    sort    = params[:sort]      || "last_post_at"

    # fetch the forum we're in
    @forum  = Forum.find(params[:id])

    # build the topic result objects
    @topics = Topic
    @topics = @topics.select("topics.*, users.username")
    @topics = @topics.select("last_poster.id as last_post_user_id, last_poster.username as last_post_username, !isnull(user_posts.id) as posted")
    @topics = @topics.select("(isnull(topic_reads.created_at < topics.last_post_at) || topic_reads.created_at < topics.last_post_at) && (topics.last_post_at > '#{Time.now - 3.days}') as unread_posts")
    @topics = @topics.joins(:user, :last_post)
    @topics = @topics.joins("INNER JOIN users as last_poster ON last_poster.id = posts.user_id")
    @topics = @topics.joins("LEFT JOIN posts as user_posts ON user_posts.topic_id = topics.id and user_posts.user_id = #{logged_in? ? current_user.id : 0}")
    @topics = @topics.joins("LEFT JOIN topic_reads as topic_reads ON topic_reads.topic_id = topics.id and topic_reads.user_id = #{logged_in? ? current_user.id : 0}")
    @topics = @topics.where("topics.forum_id = ?", @forum.id)
    #@topics = @topics.where("topics.visible = ?", 1)
    @topics = @topics.page(page)
    @topics = @topics.per(perpage)
    @topics = @topics.order('topics.sticky desc')
    @topics = @topics.order("topics.#{sort} #{order}")
    
    # announcements
    @announcements = @forum.announcements
    @announcements = @announcements.where(['starts_at <= ?', Time.now])
    @announcements = @announcements.where(['expires_at >= ?', Time.now])
    @announcements = @announcements.order('starts_at desc')

    # start breadcrumbs
    add_breadcrumb "Home", root_path
    unless @forum.ancestors.empty?
      for ancestor in @forum.ancestors
        add_breadcrumb ancestor.title, forum_path(ancestor)
      end
    end
  end

private
  # Returns an array of forum ids that a user can see based on their forum & usergroup permissions.
  #
  # This method will fetch the forums data from memcache and update their stats and last post info on-the-fly. This 
  # means we can fetch all the forums data (stats, last post info, and read status) using only 4 queries instead of the 
  # 50+ it was generating before using the lazy loading technique. I'd like to find an even better way to do this if we
  # can, this method is pretty ugly.
  #
  # @return Array
  def build_forum_index
    stats  = {}
    forums = []
    
    # build the forum stats and last post info
    Forum.all().each do |forum|
      stats = stats.merge({
        forum.id => {'topics' => forum.topic_count, 'posts' => forum.post_count, 'last_post_id' => forum.last_post_id}
      })
    end
    
    # see which forums the user can see and update it's stats and last post info
    Rails.cache.read('forums').each do |parent, children|
      break unless parent.is_active?
      forums << parent

      # check for child forums
      if children
        children.each do |child, grand|
          break unless child.is_active?

          child.topic_count  = child.topic_count + stats[child.id]['topics']
          child.post_count   = child.post_count  + stats[child.id]['posts']
          child.last_post_id = stats[child.id]['last_post_id']

          # if this forum has children, include their stats and last post info
          if child.child_list
            child.child_list.split(',').each do |child_id|
              child.topic_count = child.topic_count + stats[child_id.to_i]['topics']
              child.post_count  = child.post_count  + stats[child_id.to_i]['posts']

              if stats[child_id.to_i]['last_post_id'] > child.last_post_id
                child.last_post_id = stats[child_id.to_i]['last_post_id']
              end
            end
          end

          forums << child
        end
      end
    end

    forums
  end

  # Returns a key -> value hash of all the forums last post info.
  #
  # @param  Array  An array of post_ids to look up I.e. [1224,1347,..]
  # @return Hash   {x => <Post Object>, x => <Post Object>, ...}
  def fetch_lastposts post_ids
    last_post_data = Post.all(
        :select     => "posts.*, topics.*, users.username",
        :joins      => [:topic, :user],
        :conditions => ["posts.id in(?)", post_ids]
    )
    
    last_posts = {}
    last_post_data.map{|p|last_posts = last_posts.merge({p.forum_id => p})}
    last_posts
  end

  # Returns an array of forum ids that has unread post. This is used to change the forum's status icon and to bolded
  # unread topics.
  #
  # TODO: Use ActiveRecord to fetch the data instead of a raw sql query.
  #
  # @return Array
  def fetch_unread_forums
    sql = "
      select topics.forum_id
        from posts as posts
      left
        join topics as topics
          on posts.topic_id = topics.id
      left
        join topic_reads as topic_reads
          on posts.topic_id      = topic_reads.topic_id
         and topic_reads.user_id = '#{logged_in? ? current_user.id : 0}'
       where (isnull(topic_reads.created_at < posts.created_at) || topic_reads.created_at < posts.created_at) && 
              posts.created_at > '#{Time.now - 3.days}' = 1
      group by topics.forum_id
      order by topics.forum_id DESC
    "
    ActiveRecord::Base.connection.select_values(sql)
  end
end