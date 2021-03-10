Meteor.publish 'sub_count', (
    query=''
    picked_subtags
    nsfw
    )->
        
    match = {model:'subreddit'}
    
    # if nsfw
    #     match["data.over18"] = true
    # else 
    #     match["data.over18"] = false
    
    if picked_subtags.length > 0 then match.tags = $all:picked_subtags
    if query.length > 0
        match["data.display_name"] = {$regex:"#{query}", $options:'i'}
    Counts.publish this, 'sub_counter', Docs.find(match)
    return undefined


Meteor.publish 'subreddits', (
    query=''
    picked_subtags
    sort_key='data.subscribers'
    sort_direction=-1
    limit=20
    toggle
    nsfw
    )->
    # console.log limit
    match = {model:'subreddit'}
    
    # if nsfw
    #     match["data.over18"] = true
    # else 
    #     match["data.over18"] = false
    if picked_subtags.length > 0 then match.tags = $all:picked_subtags
    if query.length > 0
        match["data.display_name"] = {$regex:"#{query}", $options:'i'}
    # console.log 'match', match
    Docs.find match,
        limit:42
        sort: "#{sort_key}":sort_direction
        fields:
            model:1
            tags:1
            "data.display_name":1
            "data.title":1
            "data.primary_color":1
            "data.over18":1
            "data.header_title":1
            "data.created":1
            "data.header_img":1
            "data.public_description":1
            "data.advertiser_category":1
            "data.accounts_active":1
            "data.subscribers":1
            "data.banner_img":1
            "data.icon_img":1
        
        
    
Meteor.publish 'subreddit_tags', (
    picked_subtags
    toggle
    nsfw=false
    )->
    # @unblock()
    self = @
    match = {
        model:'subreddit'
    }
    # if nsfw
    #     match["data.over18"] = true
    # else 
    #     match["data.over18"] = false


    if picked_subtags.length > 0 then match.tags = $all:picked_subtags
    if picked_subtags.length > 0
        limit=10
    else 
        limit=25
    doc_count = Docs.find(match).count()
    # console.log 'doc_count', doc_count
    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_subtags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:limit }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    tag_cloud.forEach (tag, i) ->
        # console.log tag
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'subreddit_tag'
    self.ready()


Meteor.publish 'subs_tags', (
    picked_sub_tags
    picked_domains
    picked_authors
    # view_bounties
    # view_unanswered
    # query=''
    )->
    # @unblock()
    self = @
    match = {
        model:'subreddit'
        # subreddit:subreddit
    }
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    if picked_sub_tags.length > 0 then match.tags = $all:picked_sub_tags
    if picked_authors.length > 0 then match.author = $all:picked_authors
    # if picked_emotion.length > 0 then match.max_emotion_name = picked_emotion
    doc_count = Docs.find(match).count()
    sus_tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: picked_sub_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:42 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    sus_tag_cloud.forEach (tag, i) ->
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'subs_tag'
    
    
    subreddit_author_cloud = Docs.aggregate [
        { $match: match }
        { $project: "author": 1 }
        # { $unwind: "$author" }
        { $group: _id: "$author", count: $sum: 1 }
        # { $match: _id: $nin: picked_authors }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:7 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    subreddit_author_cloud.forEach (author, i) ->
        self.added 'results', Random.id(),
            name: author.name
            count: author.count
            model:'subreddit_author_tag'
  
    self.ready()


Meteor.methods    
    # search_subreddits: (search)->
    #     @unblock()
    #     HTTP.get "http://reddit.com/subreddits/search.json?q=#{search}&raw_json=1&nsfw=1", (err,res)->
    #         if res.data.data.dist > 1
    #             _.each(res.data.data.children[0..200], (item)=>
    #                 found = 
    #                     Docs.findOne    
    #                         model:'subreddit'
    #                         "data.display_name":item.data.display_name
    #                 # if found
    #                 unless found
    #                     item.model = 'subreddit'
    #                     Docs.insert item
    #             )
    search_subreddits: (search)->
        # console.log 'searching subs', search
        @unblock()
        HTTP.get "http://reddit.com/subreddits/search.json?q=#{search}&raw_json=1&nsfw=1&include_over_18=off&limit=10", (err,res)->
            if res.data.data.dist > 1
                _.each(res.data.data.children[0..100], (item)=>
                    # console.log item.data.display_name
                    added_tags = [search]
                    added_tags = _.flatten(added_tags)
                    # console.log 'added tags', added_tags
                    found = 
                        Docs.findOne    
                            model:'subreddit'
                            "data.display_name":item.data.display_name
                    if found
                        # console.log 'found', search, item.data.display_name
                        Docs.update found._id, 
                            $addToSet: tags: $each: added_tags
                    unless found
                        # console.log 'not found', item.data.display_name
                        item.model = 'subreddit'
                        item.tags = added_tags
                        Docs.insert item
                        
                )
        

        
