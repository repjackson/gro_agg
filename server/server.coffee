Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id
        
Meteor.publish 'love', (doc_id)->
    Docs.find
        model:'love'
        

Meteor.publish 'wikis', (
    w_query
    picked_tags
    )->
    Docs.find({
        model:'wikipedia'
    },{ 
        limit:10
    })
    


Meteor.publish 'doc_by_title', (title)->
    Docs.find({
        title:title
        model:'wikipedia'
        "watson.metadata.image":$exists:true
    }, {
        fields:
            title:1
            "watson.metadata.image":1
    })


Meteor.publish 'comments', (doc_id)->
    Docs.find
        model:'comment'
        parent_id:doc_id


        

Meteor.publish 'doc_comments', (doc_id)->
    Docs.find
        model:'comment'
        parent_id:doc_id


Meteor.publish 'children', (model, parent_id)->
    match = {}
    Docs.find
        model:model
        parent_id:parent_id

Meteor.publish 'current_doc', (doc_id)->
    console.log 'pulling doc'
    Docs.find doc_id





Meteor.publish 'model_docs', (model)->
    # console.log 'pulling doc'
    match = {model:model}
    # if Meteor.user()
    #     unless Meteor.user().roles and 'admin' in Meteor.user().roles
    #         match.app = 'stand'
    # else
        # match.app = 'stand'
    Docs.find match



Meteor.publish 'doc', (doc_id)->
    found_doc = Docs.findOne doc_id
    if found_doc
        Docs.find doc_id
    else
        Meteor.users.find doc_id
        
        
        
# tsqp-gebk-xhpz-eobp-agle
Docs.allow
    insert: (userId, doc) -> true
    update: (userId, doc) -> true
    remove: (userId, doc) -> false

# Meteor.publish 'model_count', (
#     model
#     )->
#     match = {model:model}
    
#     Counts.publish this, 'model_counter', Docs.find(match)
#     return undefined


Meteor.methods
    # hi: ->
    # stringify_tags: ->
    #     docs = Docs.find({
    #         tags: $exists: true
    #         tags_string: $exists: false
    #     },{limit:1000})
    #     for doc in docs.fetch()
    #         # doc = Docs.findOne id
    #         tags_string = doc.tags.toString()
    #         Docs.update doc._id,
    #             $set: tags_string:tags_string
    #




Meteor.publish 'parent_doc', (doc_id)->
    doc = Docs.findOne doc_id
    Docs.find 
        _id:doc.parent_id



Meteor.publish 'doc_count', (
    picked_tags
    # picked_authors
    # picked_locations
    # picked_times
    )->
    @unblock()
    match = {
        model:'post'
        is_private:$ne:true
    }
    # unless Meteor.userId()
    #     match.privacy='public'

        
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    # if picked_authors.length > 0 then match.author = $all:picked_authors
    # if picked_locations.length > 0 then match.location = $all:picked_locations
    # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times

    Counts.publish this, 'doc_count', Docs.find(match)
    return undefined
            
Meteor.publish 'posts', (
    picked_tags
    picked_times
    picked_locations
    picked_authors
    sort_key
    sort_direction
    skip=0
    view_videos
    view_images
    )->
        
    # @unblock()
    self = @
    match = {
        model:$in:['post','rpost']
        is_private:$ne:true
        # group:$exists:false
    }
    # unless Meteor.userId()
    #     match.privacy='public'
    
    if sort_key
        sk = sort_key
    else
        sk = 'points'
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    # match.tags = $all:picked_tags
    if picked_locations.length > 0 then match.location = $all:picked_locations
    if picked_authors.length > 0 then match.author = $all:picked_authors
    if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    if view_videos
        match.youtube_id = $exists:true
    if view_images
        match.image_id = $exists:true

    # console.log 'match',match
    Docs.find match,
        limit:10
        sort: "#{sk}":-1
        # skip:skip*20
        # fields:
        #     title:1
        #     content:1
        #     body:1
        #     description:1
        #     tags:1
        #     image_id:1
        #     image_link:1
        #     url:1
        #     youtube_id:1
        #     _timestamp:1
        #     _timestamp_tags:1
        #     views:1
        #     points:1
        #     anger_points:1
        #     sad_points:1
        #     joy_points:1
        #     disgust_points:1
        #     model:1
    
    
# Meteor.methods    
    # tagify_love: (love)->
    #     doc = Docs.findOne love
    #     # moment(doc.date).fromNow()
    #     # authorstamp = Date.now()

    #     doc._authorstamp_long = moment(doc._authorstamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    #     # doc._app = 'love'
    
    #     date = moment(doc.date).format('Do')
    #     weekdaynum = moment(doc.date).isoWeekday()
    #     weekday = moment().isoWeekday(weekdaynum).format('dddd')
    
    #     hour = moment(doc.date).format('h')
    #     minute = moment(doc.date).format('m')
    #     ap = moment(doc.date).format('a')
    #     month = moment(doc.date).format('MMMM')
    #     year = moment(doc.date).format('YYYY')
    
    #     # doc.points = 0
    #     # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    #     date_array = [ap, weekday, month, date, year]
    #     if _
    #         date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
    #         doc._authorstamp_tags = date_array
    #         # console.log 'love', date_array
    #         Docs.update love, 
    #             $set:addedauthors:date_array
    
           
Meteor.publish 'dao_tags', (
    picked_tags
    picked_times
    picked_locations
    picked_authors
    query=''
    view_videos
    view_images
    )->
    # @unblock()
    self = @
    match = {
        model:$in:['post','rpost']
        is_private:$ne:true
    }


    # unless Meteor.userId()
    #     match.privacy='public'

    if picked_tags.length > 0 then match.tags = $all:picked_tags
    # match.tags = $all:picked_tags
    if picked_authors.length > 0 then match.author = $all:picked_authors
    if picked_locations.length > 0 then match.location = $all:picked_locations
    if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    
    if view_videos
        match.youtube_id = $exists:true
    if view_images
        match.image_id = $exists:true
    
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
        { $limit:20 }
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
        
Meteor.methods  
    search_reddit: (query)->
        console.log 'searching reddit'
        # @unblock()
        # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "http://reddit.com/search.json?q=#{query}&over_18=1&limit=100&include_facets=false&raw_json=1"
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,res)=>
        HTTP.get url,(err,res)=>
            if res.data.data.dist > 1
                _.each(res.data.data.children, (item)=>
                    unless item.domain is "OneWordBan"
                        data = item.data
                        # console.log data
                        len = 200
                        added_tags = [query]
                        # added_tags = [query]
                        # added_tags.push data.domain.toLowerCase()
                        # added_tags.push data.subreddit.toLowerCase()
                        # added_tags.push data.author.toLowerCase()
                        added_tags = _.flatten(added_tags)
                        reddit_post =
                            reddit_id: data.id
                            url: data.url
                            domain: data.domain
                            comment_count: data.num_comments
                            permalink: data.permalink
                            ups: data.ups
                            points: data.ups
                            title: data.title
                            subreddit: data.subreddit
                            group:data.subreddit
                            group_lowered:data.subreddit.toLowerCase()
                            # root: query
                            # selftext: false
                            # thumbnail: false
                            tags: added_tags
                            model:'rpost'
                            # source:'reddit'
                            data:data
                        existing = Docs.findOne 
                            model:'rpost'
                            url:data.url
                        if existing
                            # if Meteor.isDevelopment
                            #     console.log 'new search doc', reddit_post.title
                            # if typeof(existing.tags) is 'string'
                            #     Doc.update
                            #         $unset: tags: 1
                            Docs.update existing._id,
                                $addToSet: tags: $each: added_tags
                                $set:
                                    data:data
                                    points:data.ups

                            Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
                        unless existing
                            # if Meteor.isDevelopment
                            #     console.log 'new search doc', reddit_post.title
                            new_reddit_post_id = Docs.insert reddit_post
                            Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                )
   

    get_reddit_post: (doc_id, reddit_id, root)->
        @unblock()
        doc = Docs.findOne doc_id
        if doc.reddit_id
            # HTTP.get "http://reddit.com/by_id/t3_#{doc.reddit_id}.json&raw_json=1", (err,res)->
            HTTP.get "https://www.reddit.com/comments/#{doc.reddit_id}/.json", (err,res)->
                if err
                    console.log 'error getting', doc.reddit_id
                    # console.error err
                unless err
                    # console.log res.data[0].data.children[0].data
                    rd = res.data[0].data.children[0].data
                    Docs.update doc_id,
                        $set:
                            data: rd
                            url: rd.url
                            # reddit_image:rd.preview.images[0].source.url
                            thumbnail: rd.thumbnail
                            subreddit: rd.subreddit
                            group:rd.subreddit
                            author: rd.author
                            domain: rd.domain
                            is_video: rd.is_video
                            ups: rd.ups
                            # downs: rd.downs
                            over_18: rd.over_18

        