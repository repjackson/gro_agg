Meteor.methods
    remove_doc: (doc_id)->
        Docs.remove doc_id

        

# Meteor.publish 'wikis', (
#     w_query
#     picked_tags
#     )->
#     Docs.find({
#         model:'wikipedia'
#     },{ 
#         limit:10
#     })
    


Meteor.publish 'doc_by_title', (title)->
    @unblock()
    Docs.find({
        title:title
        model:'wikipedia'
        "watson.metadata.image":$exists:true
    }, {
        fields:
            title:1
            "watson.metadata.image":1
    })




Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id
        
        
        
# tsqp-gebk-xhpz-eobp-agle
Docs.allow
    insert: (userId, doc) -> true
    update: (userId, doc) -> false
    remove: (userId, doc) -> false


Meteor.publish 'post_count', (
    picked_tags
    # picked_authors
    # picked_locations
    # picked_times
    )->
    @unblock()
    match = {
        model:'rpost'
        # is_private:$ne:true
    }
    # unless Meteor.userId()
    #     match.privacy='public'

        
    match.tags = $all:picked_tags
    # if picked_authors.length > 0 then match.author = $all:picked_authors
    # if picked_locations.length > 0 then match.location = $all:picked_locations
    # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times

    Counts.publish this, 'post_count', Docs.find(match)
    return undefined
            
Meteor.publish 'rposts', (
    picked_tags
    picked_domains
    picked_authors
    picked_time_tags
    sort_key='data.ups'
    sort_direction=-1
    limit=20
    # picked_times
    # picked_locations
    # picked_authors
    # skip=0
    )->
        
    @unblock()
    self = @
    match = {
        model:'rpost'
        # is_private:$ne:true
        # group:$exists:false
    }
    # unless Meteor.userId()
    #     match.privacy='public'
    
    # if sort_key
    #     sk = sort_key
    # else
    #     sk = '_timestamp'
    # if nsfw
    #     match['data.over_18'] = true
    # else
    match['data.over_18'] = false
    
    # if picked_tags.length > 0 then match.tags = $all:picked_tags
    match.tags = $all:picked_tags
    # if picked_locations.length > 0 then match.location = $all:picked_locations
    if picked_authors.length > 0 then match['data.author'] = $all:picked_authors
    if picked_domains.length > 0 then match['data.domain'] = $all:picked_domains
    # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times

    Docs.find match,
        limit:limit
        sort: "#{sort_key}":-1
        # skip:skip*20
        fields:
            title:1
            tags:1
            url:1
            model:1
            # data:1    
            "watson.metadata.image":1
            "data.domain":1
            "data.author":1
            "data.permalink":1
            "permalink":1
            "data.title":1
            "data.created_utc":1
            "data.subreddit":1
            "data.url":1
            "data.thumbnail":1
            "data.media.oembed":1
            analyzed_text:1
            "data.url":1
            permalink:1
            "data.media":1

    
    
           
Meteor.publish 'tags', (
    picked_tags
    toggle
    picked_domains
    picked_authors
    picked_time_tags
    # query=''
    )->
    @unblock()
    self = @
    match = {
        model:'rpost'
        # model:'post'
        # is_private:$ne:true
        # sublove:sublove
    }


    # unless Meteor.userId()
    #     match.privacy='public'
    # if nsfw
    #     match['data.over_18'] = true
    # else
    match['data.over_18'] = false

    # if picked_tags.length > 0 then match.tags = $all:picked_tags
    match.tags = $all:picked_tags
    if picked_authors.length > 0 then match.author = $all:picked_authors
    if picked_domains.length > 0 then match.domain = $all:picked_domains
    # if picked_locations.length > 0 then match.location = $all:picked_locations
    # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    doc_count = Docs.find(match).count()
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
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'tag'
    
    location_cloud = Docs.aggregate [
        { $match: match }
        { $project: "location_tags": 1 }
        { $unwind: "$location_tags" }
        { $group: _id: "$location_tags", count: $sum: 1 }
        # { $match: _id: $nin: picked_location }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:10 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    location_cloud.forEach (location, i) ->
        self.added 'results', Random.id(),
            name: location.name
            count: location.count
            model:'location_tag'
    
    
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
    # timestamp_cloud.forEach (time, i) ->
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
    # timestamp_cloud.forEach (time, i) ->
    #     self.added 'results', Random.id(),
    #         name: time.name
    #         count: time.count
    #         model:'time_tag'
    
    
    
    author_cloud = Docs.aggregate [
        { $match: match }
        { $project: "data.author": 1 }
        # { $unwind: "$author" }
        { $group: _id: "$data.author", count: $sum: 1 }
        { $match: _id: $nin: picked_authors }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:10 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    author_cloud.forEach (author, i) ->
        self.added 'results', Random.id(),
            name: author.name
            count: author.count
            model:'author'
    
    domain_cloud = Docs.aggregate [
        { $match: match }
        { $project: "data.domain": 1 }
        # { $unwind: "$author" }
        { $group: _id: "$data.domain", count: $sum: 1 }
        { $match: _id: $nin: picked_authors }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:10 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    domain_cloud.forEach (domain, i) ->
        self.added 'results', Random.id(),
            name: domain.name
            count: domain.count
            model:'domain'
    
    self.ready()
    
    
    
Meteor.publish 'user_doc', (username)->
    match = {
        model:'user'
        username:username
    }
    # unless Meteor.isDevelopment
    # match["data.subreddit.over_18"] = $ne:true 
    Docs.find match
    