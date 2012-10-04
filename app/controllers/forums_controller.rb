class ForumsController < ApplicationController
  # /forums
  def index
    @forumbits  = build_forums_list
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

    # forum objects
    @forum      = Forum.find(params[:id])
    @children   = build_forums_list @forum.id
    @lightbulbs = fetch_unread_forums
    @lastposts  = fetch_lastposts @children.map(&:last_post_id).flatten.delete_if {|x| x == 0 }

    # TODO: Check if there's a better way to build the topics object than this
    @topics = Topic.select("topics.*, users.username")
    @topics = @topics.select("last_poster.id as last_post_user_id, last_poster.username as last_post_username")
    @topics = @topics.select("(select count(id) from posts where topic_id = topics.id and user_id = #{logged_in? ? current_user.id : 0} and visible = 1) as posted")
    @topics = @topics.select("(isnull(topic_reads.created_at < topics.last_post_at) || topic_reads.created_at < topics.last_post_at) && (topics.last_post_at > '#{Time.now - 3.days}') as unread_posts")
    @topics = @topics.joins(:user, :last_post)
    @topics = @topics.joins("INNER JOIN users as last_poster ON last_poster.id = posts.user_id")
    @topics = @topics.joins("LEFT JOIN topic_reads as topic_reads ON topic_reads.topic_id = topics.id and topic_reads.user_id = #{logged_in? ? current_user.id : 0}")
    @topics = @topics.where("topics.forum_id = ?", @forum.id)
    #@topics = @topics.where("topics.visible = ?", 1)
    @topics = @topics.page(page)
    @topics = @topics.per(perpage)
    @topics = @topics.order('topics.sticky desc')
    @topics = @topics.order("topics.#{sort} #{order}")

    # announcements
    @announcements = @forum.announcements
    @announcements = @announcements.where(['starts_at  <= ?', Time.now])
    @announcements = @announcements.where(['expires_at >= ?', Time.now])
    @announcements = @announcements.order('starts_at desc')

    # breadcrumbs
    add_breadcrumb "Home", root_path
    unless @forum.ancestors.empty?
      for ancestor in @forum.ancestors
        add_breadcrumb ancestor.title, forum_path(ancestor)
      end
    end
  end

private
  # Returns an array of all active forums based on the user's permissions.
  #
  # This method will fetch the forums data from memcache (as opposed to MySQL) and update the stats, unread and last 
  # post info on-the-fly, saving us on a number of database calls. The cached data is updated anytime a change is made 
  # to the forums via the admin panel. For example, if you changed the forum's title, the cache data would get rebuilt. 
  # The downside to this method is we still have to query the database to get the lastest stats, last post and unread
  # info. Still better than the lazy loading technique where it was generating over 60 queries, more when more forums
  # were present.
  #
  # I'd be interested in refactoring this technique if there's a more efficient way to do it. Due to time constrants I
  # wasn't able to put more thought into this.
  #
  # @param  Integer   Build the tree starting at forum_id. Zero = build all forums.
  # @return Array     An array of forum objects a user can see based on the user and forum permissions.
  def build_forums_list parent_id = 0
    stats = {} # A hash that holds the forums latest stats and last post ids
    tree  = [] # The array used to build the forum's tree

    # get the lastest forum stats and last post ids
    Forum.all().each do |forum|
      stats = stats.merge({
        forum.id => {'topics' => forum.topic_count, 'posts' => forum.post_count, 'last_post_id' => forum.last_post_id}
      })
    end
    
    # build the forums tree
    Rails.cache.read('forums').each do |parent, children|
      if parent_id == 0 or parent.id == parent_id
        break unless parent.is_active?
        tree << parent 
      end

      # TODO: this needs to be moved in the above block in order for the forum perms to work. If the user doesn't have
      # permissions to the parent forum, then it's child forums will inherit the same permissions.
      if parent.is_active?
        build_child_forums children, tree, stats, parent_id
      end
    end
    
    return tree
  end

  # Recursive function that builds a forum (checking permissions, etc.) and adds it and it's children to an array of
  # forums (tree) the the user can access.
  #
  # @param  Hash      A list of forums and their children to walk through and build
  # @param  Array     The forum tree to add to if the user has permission to see the forum
  # @param  Hash      A hash of all the forum stats and last post ids
  # @param  Integer   Build the tree starting at forum_id. Zero = build all forums.
  # @return Array     An array of forum objects a user can see based on the user and forum permissions.
  def build_child_forums forums, tree, stats, parent_id
    forums.each do |forum, children|
      break unless forum.is_active?

      if parent_id != 0
        break unless forum.id == parent_id or forum.ancestry.split('/').map(&:to_i).include?(parent_id)
      end
      
      # update forum stats and last_post_id
      forum.topic_count  = stats[forum.id]['topics']
      forum.post_count   = stats[forum.id]['posts']
      forum.last_post_id = stats[forum.id]['last_post_id']

      # include sub-forum stats too
      if forum.child_list?
        forum.child_list.split('/').each do |forum_id|
          forum.topic_count = forum.topic_count + stats[forum_id.to_i]['topics']
          forum.post_count  = forum.post_count + stats[forum_id.to_i]['posts']
        end
      end
      
      # add forum to tree
      tree << forum
      
      # check for children
      build_child_forums children, tree, stats, parent_id
    end
    
    return tree
  end

  # Returns a key -> value hash of all the forums last post info.
  #
  # @param  Array     An array of post_ids to look up [1224,1347,..]
  # @return Hash      {x => <Post Object>, x => <Post Object>, ...}
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

  # Returns an array of forum ids that contain unread posts. Used to change the forum's status icons (aka: lightbulbs).
  #
  # TODO: Use ActiveRecord to fetch the data instead of a raw sql query if we can.
  #
  # @return Array     Array of forum_ids that contain unread posts
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