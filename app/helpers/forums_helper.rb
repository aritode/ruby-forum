module ForumsHelper
  # Builds an array of forum data based on the ids and collection info passed
  #
  # @parm Array   The array of forum ids to build
  # @parm Array   An Array of all the forums present in the database (avoids querying the db)
  def build_child_info(ids, collection)
    forums = []
    for forum in collection
      if ids.include?(forum.id)
          forums.push(forum)
      end
    end
    return forums
  end
end
