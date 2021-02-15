request = require('request')
rp = require('request-promise');
# tsqp-gebk-xhpz-eobp-agle
Docs.allow
    insert: (userId, doc) -> true
    update: (userId, doc) -> true
    remove: (userId, doc) -> true


Meteor.methods
    # hi: ->
    # stringify_tags: ->
    #     docs = Docs.find({
    #         tags: $exists: true
    #         tags_string: $exists: false
    #     },{limit:500})
    #     for doc in docs.fetch()
    #         # doc = Docs.findOne id
    #         tags_string = doc.tags.toString()
    #         Docs.update doc._id,
    #             $set: tags_string:tags_string
    #

Meteor.publish 'count', (
    picked_tags
    )->
    match = {
        model:'rpost'
    }

    match.tags = $all:picked_tags
    if picked_tags.length
        Counts.publish this, 'counter', Docs.find(match)
        return undefined
            
Meteor.publish 'posts', (
    picked_tags
    )->
    self = @
    match = {
        model:'rpost'
    }
    if picked_tags.length
        match.tags = $all:picked_tags
        
    
        console.log 'match', match
        Docs.find match,
            limit: 20
            # sort: "#{sk}":-1
            sort: ups:-1
            fields:
                "data.title":1
                "data.subreddit":1
                "data.thumbnail_width":1
                "data.thumbnail":1
                "data.media":1
                "data.created":1
                "subreddit":1
                tags:1
                tags:1
                url:1
                model:1
                ups:1
                domain:1
                # data:1
    
    
           
Meteor.publish 'tags', (
    picked_tags
    toggle
    )->
    # @unblock()
    self = @
    match = {
        model: 'rpost'
    }
    if picked_tags.length
        match.tags = $all:picked_tags
        doc_count = Docs.find(match).count()
        console.log 'doc_count', doc_count
        console.log 'tag match', match
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:15 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        tag_cloud.forEach (tag, i) ->
            # console.log tag
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tag'
        
        
        self.ready()
        
        
        


Meteor.methods
    search_reddit: (query)->
        console.log 'searching reddit'
        @unblock()
        # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "http://reddit.com/search.json?q=#{query}&nsfw=1&limit=100&include_facets=false&raw_json=1"
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
                                $set:data:data

                            # Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
                        unless existing
                            # if Meteor.isDevelopment
                            #     console.log 'new search doc', reddit_post.title
                            new_reddit_post_id = Docs.insert reddit_post
                            # Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                )
   

    get_reddit_post: (doc_id, reddit_id, root)->
        # @unblock()
        doc = Docs.findOne doc_id
        if doc.reddit_id
            HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json&raw_json=1", (err,res)->
                if err then console.error err
                else
                    rd = res.data.data.children[0].data
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

                
        
    # tagify_time_rpost: (doc_id)->
    #     doc = Docs.findOne doc_id
    #     # moment.unix(doc.data.created).fromNow()
    #     # timestamp = Date.now()
    #     if doc.data and doc.data.created
    #         doc._timestamp_long = moment.unix(doc.data.created).format("dddd, MMMM Do YYYY, h:mm:ss a")
    #         # doc._app = 'dao'
        
    #         date = moment.unix(doc.data.created).format('Do')
    #         weekdaynum = moment.unix(doc.data.created).isoWeekday()
    #         weekday = moment().isoWeekday(weekdaynum).format('dddd')
        
    #         hour = moment.unix(doc.data.created).format('h')
    #         minute = moment.unix(doc.data.created).format('m')
    #         ap = moment.unix(doc.data.created).format('a')
    #         month = moment.unix(doc.data.created).format('MMMM')
    #         year = moment.unix(doc.data.created).format('YYYY')
        
    #         # doc.points = 0
    #         # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    #         date_array = [ap, weekday, month, date, year]
    #         if _
    #             date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
    #             doc.timestamp_tags = date_array
    #             # console.log date_array
    #             Docs.update doc_id, 
    #                 $set:time_tags:date_array
                            

                