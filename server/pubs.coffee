
Meteor.publish 'post_count', (
    picked_tags
    picked_authors
    picked_locations
    picked_times
    view_images
    view_videos
    view_adult
    )->
    # @unblock()
    match = {
        model:'rpost'
        # is_private:$ne:true
    }
    # unless Meteor.userId()
    #     match.privacy='public'

    if view_adult
        match["data.over_18"] = true
    else 
        match["data.over_18"] = false
    match.tags = $all:picked_tags
    # if picked_authors.length > 0 then match.author = $all:picked_authors
    # if picked_locations.length > 0 then match.location = $all:picked_locations
    # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times

    Counts.publish this, 'post_counter', Docs.find(match)
    return undefined
            
Meteor.publish 'rpost_comments', (subreddit, doc_id)->
    post = Docs.findOne doc_id
    Docs.find
        model:'rcomment'
        parent_id:"t3_#{post.reddit_id}"
Meteor.publish 'posts', (
    picked_tags
    toggle
    picked_times
    picked_locations
    picked_authors
    sort_key
    sort_direction
    skip=0
    view_videos
    view_images
    view_adult
    )->
        
    # @unblock()
    self = @
    match = {
        model:'rpost'
        # is_private:$ne:true
        # group:$exists:false
    }
    # unless Meteor.userId()
    #     match.privacy='public'
    
    if sort_key
        sk = sort_key
    else
        sk = 'points'
    # if picked_tags.length > 0 then match.tags = $all:picked_tags
    match.tags = $all:picked_tags
    # if picked_locations.length > 0 then match.location = $all:picked_locations
    # if picked_authors.length > 0 then match.author = $all:picked_authors
    # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    if view_adult
        match["data.over_18"] = true
    else 
        match["data.over_18"] = false

    if view_videos
        match["data.domain"] = $in: ['youtube.com','youtu.be','m.youtube.com','vimeo.com','v.redd.it']
        
    else if view_images
        match["data.domain"] = $in: ['i.reddit.com','i.redd.it','i.imgur.com','imgur.com','gyfycat.com','giphy.com']

    # console.log 'match',match
    Docs.find match,
        limit:20
        sort: "#{sk}":-1
        # skip:skip*20
        fields:
            _id:1
            # data:1
            "data.thumbnail":1
            "data.domain":1
            "data.media":1
            "data.link_url":1
            "data.is_reddit_media_domain":1
            "data.created":1
            "data.url":1
            "data.preview.images[0].source.url":1

            # "data.selftext":1
            subreddit:1
            # "data.selftext_html":1
            comment_count:1
            title:1
            domain:1
            reddit_id:1
            ups:1
            tags:1
            thumbnail:1
            url:1
            _timestamp:1
            _timestamp_tags:1
            views:1
            points:1
            model:1
    
    
           
Meteor.publish 'dao_tags', (
    picked_tags
    toggle
    picked_times
    picked_locations
    picked_authors
    query=''
    view_videos
    view_images
    view_adult
    )->
    # @unblock()
    self = @
    match = {
        model:'rpost'
    }


    # unless Meteor.userId()
    #     match.privacy='public'

    # if picked_tags.length > 0 then match.tags = $all:picked_tags
    match.tags = $all:picked_tags
    if picked_authors.length > 0 then match.author = $all:picked_authors
    if picked_locations.length > 0 then match.location = $all:picked_locations
    if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    
    if view_adult
        match["data.over_18"] = true
    else 
        match["data.over_18"] = false
        
    if view_videos
        match["data.domain"] = $in: ['youtube.com','youtu.be','m.youtube.com','vimeo.com','v.redd.it']
        
    else if view_images
        match["data.domain"] = $in: ['i.reddit.com','i.redd.it','i.imgur.com','imgur.com','gyfycat.com','giphy.com']

    doc_count = Docs.find(match).count()
    # console.log 'doc_count', doc_count
    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:10 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    tag_cloud.forEach (tag, i) ->
        # console.log tag
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'tag'
    
    # location_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "location_tags": 1 }
    #     { $unwind: "$location_tags" }
    #     { $group: _id: "$location_tags", count: $sum: 1 }
    #     # { $match: _id: $nin: picked_location }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:10 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # location_cloud.forEach (location, i) ->
    #     self.added 'results', Random.id(),
    #         name: location.name
    #         count: location.count
    #         model:'location_tag'
    
    
    # timestamp_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "timestamp_tags": 1 }
    #     { $unwind: "$timestamp_tags" }
    #     { $group: _id: "$timestamp_tags", count: $sum: 1 }
    #     # { $match: _id: $nin: picked_time }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:10 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # # console.log match
    # timestamp_cloud.forEach (time, i) ->
    #     # console.log 'time', time
    #     self.added 'results', Random.id(),
    #         name: time.name
    #         count: time.count
    #         model:'timestamp_tag'
    
    
    # time_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "time_tags": 1 }
    #     { $unwind: "$time_tags" }
    #     { $group: _id: "$time_tags", count: $sum: 1 }
    #     # { $match: _id: $nin: picked_time }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:10 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # # console.log match
    # timestamp_cloud.forEach (time, i) ->
    #     # console.log 'time', time
    #     self.added 'results', Random.id(),
    #         name: time.name
    #         count: time.count
    #         model:'time_tag'
    
    
    
    # author_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "author": 1 }
    #     # { $unwind: "$author" }
    #     { $group: _id: "$author", count: $sum: 1 }
    #     { $match: _id: $nin: picked_authors }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:10 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # author_cloud.forEach (author, i) ->
    #     self.added 'results', Random.id(),
    #         name: author.name
    #         count: author.count
    #         model:'author'
    
    
    self.ready()
    
    
    
Meteor.publish 'rpost_comment_tags', (
    subreddit
    parent_id
    picked_tags
    # view_bounties
    # view_unanswered
    # query=''
    )->
    # @unblock()
    
    parent = Docs.findOne parent_id
    
    self = @
    match = {
        model:'rcomment'
        parent_id:"t3_#{parent.reddit_id}"
    }
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    # if picked_tags.length > 0 then match.tags = $all:picked_tags
    # if selected_emotion.length > 0 then match.max_emotion_name = selected_emotion
    doc_count = Docs.find(match).count()
    # console.log 'doc_count', doc_count
    # console.log 'match', match
    rpost_comment_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:11 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    rpost_comment_cloud.forEach (tag, i) ->
        # console.log tag
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'rpost_comment_tag'
            
    self.ready()
            
    