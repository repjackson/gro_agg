request = require('request')
rp = require('request-promise');


Meteor.methods
    search_reddit: (query)->
        # console.log 'searching reddit'
        @unblock()
        # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "http://reddit.com/search.json?q=#{query}&nsfw=1&limit=20&include_facets=false&raw_json=1"
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,res)=>
        HTTP.get url,(err,res)=>
            if res.data.data.dist > 1
                _.each(res.data.data.children, (item)=>
                    unless item.domain is "OneWordBan"
                        data = item.data
                        len = 200
                        # if typeof(query) is String
                        #     added_tags = [query]
                        # else
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

                            # Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
                        unless existing
                            # if Meteor.isDevelopment
                            #     console.log 'new search doc', reddit_post.title
                            new_reddit_post_id = Docs.insert reddit_post
                            Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                )
   
    reddit_best: (query)->
        @unblock()
        # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "http://reddit.com/best.json?q=#{query}&nsfw=1&limit=30&include_facets=false&raw_json=1"
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,res)=>
        HTTP.get url,(err,res)=>
            if res.data.data.dist > 1
                _.each(res.data.data.children, (item)=>
                    unless item.domain is "OneWordBan"
                        data = item.data
                        len = 200
                        # if typeof(query) is String
                        #     added_tags = [query]
                        # else
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
                            # root: query
                            # selftext: false
                            # thumbnail: false
                            tags: added_tags
                            model:'rpost'
                            # source:'reddit'
                        existing = Docs.findOne 
                            model:'rpost'
                            url:data.url
                        if existing
                            # if Meteor.isDevelopment
                            #     console.log 'existing best doc', existing.url
                            # if typeof(existing.tags) is 'string'
                            #     Doc.update
                            #         $unset: tags: 1
                            Docs.update existing._id,
                                $addToSet: tags: $each: added_tags
                            Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
                        unless existing
                            new_reddit_post_id = Docs.insert reddit_post
                            # if Meteor.isDevelopment
                            #     console.log 'new best doc', reddit_post.title
                            # Meteor.users.update Meteor.userId(),
                            #     $inc:points:1
                            Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                )
    
    reddit_new: (query)->
        @unblock()
        # console.log 'searching sub'

        # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "http://reddit.com/new.json?q=#{query}&nsfw=1&limit=30&include_facets=false&raw_json=1"
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,res)=>
        HTTP.get url,(err,res)=>
            if res.data.data.dist > 1
                _.each(res.data.data.children, (item)=>
                    unless item.domain is "OneWordBan"
                        data = item.data
                        len = 200
                        # if typeof(query) is String
                        #     added_tags = [query]
                        # else
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
                            # root: query
                            # selftext: false
                            # thumbnail: false
                            tags: added_tags
                            model:'rpost'
                            # source:'reddit'
                        existing = Docs.findOne 
                            model:'rpost'
                            url:data.url
                        if existing
                            # if Meteor.isDevelopment
                            #     console.log 'existing new doc', existing._id
                            # if typeof(existing.tags) is 'string'
                            #     Doc.update
                            #         $unset: tags: 1
                            Docs.update existing._id,
                                $addToSet: tags: $each: added_tags
                            Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
                        unless existing
                            new_reddit_post_id = Docs.insert reddit_post
                            # if Meteor.isDevelopment
                            #     console.log 'new new doc', reddit_post.title
        
                            # Meteor.users.update Meteor.userId(),
                            #     $inc:points:1
                            Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                )
    
    calc_sub_tags: (subreddit)->
        found = 
            Docs.findOne(
                model:'subreddit'
                "data.display_name": subreddit
            )
        sub_tags = Meteor.call 'agg_sub_tags', subreddit
        # console.log 'sub tags', sub_tags
        titles = _.pluck(sub_tags, 'title')
        # console.log 'titles', titles
        if found
            Docs.update found._id, 
                $set:tags:titles
        Meteor.call 'clear_blocklist_doc', found._id, ->

    agg_sub_tags: (subreddit)->
        match = {model:'rpost', subreddit:subreddit}
        total_doc_result_count =
            Docs.find( match,
                {
                    fields:
                        _id:1
                }
            ).count()
        # console.log total_doc_result_count, 'docs'
        # limit=20
        options = {
            explain:false
            allowDiskUse:true
        }

        pipe =  [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ]

        if pipe
            agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # else
            res = {}
            if agg
                agg.toArray()
                # omega = Docs.findOne model:'omega_session'
                # Docs.update omega._id,
                #     $set:
                #         agg:agg.toArray()
        else
            return null

        
        
        
    get_sub_latest: (subreddit)->
        @unblock()
        # console.log 'getting latest', subreddit
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "https://www.reddit.com/r/#{subreddit}.json?&raw_json=1&nsfw=1"
        HTTP.get url,(err,res)=>
            # console.log res.data.data.children.length
            # if res.data.data.dist > 1
            _.each(res.data.data.children[0..100], (item)=>
                # console.log item.data.id
                found = 
                    Docs.findOne    
                        model:'rpost'
                        reddit_id:item.data.id
                        # subreddit:item.data.id
                if found
                    # console.log found, 'found'
                    Docs.update found._id,
                        $set:subreddit:item.data.subreddit
                unless found
                    # console.log found, 'not found'
                    item.model = 'rpost'
                    item.reddit_id = item.data.id
                    item.author = item.data.author
                    item.subreddit = item.data.subreddit
                    # item.rdata = item.data
                    Docs.insert item
            )
            
            
    get_post_comments: (subreddit, doc_id)->
        @unblock()
        console.log 'getting post comments', subreddit, doc_id
        doc = Docs.findOne doc_id
        
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        # https://www.reddit.com/r/uwo/comments/fhnl8k/ontario_to_close_all_public_schools_for_two_weeks.json
        url = "https://www.reddit.com/r/#{subreddit}/comments/#{doc.reddit_id}.json?&raw_json=1&nsfw=1"
        HTTP.get url,(err,res)=>
            # console.log res.data.data.children.length
            # if res.data.data.dist > 1
            # [1].data.children[0].data.body
            _.each(res.data[1].data.children[0..100], (item)=>
                # console.log item
                found = 
                    Docs.findOne    
                        model:'rcomment'
                        reddit_id:item.data.id
                        parent_id:item.data.parent_id
                        # subreddit:item.data.id
                # if found
                #     console.log found, 'found comment'
                #     # Docs.update found._id,
                #     #     $set:subreddit:item.data.subreddit
                unless found
                    # console.log found, 'not found comment'
                    item.model = 'rcomment'
                    item.reddit_id = item.data.id
                    item.parent_id = item.data.parent_id
                    item.subreddit = subreddit
                    Docs.insert item
            )
    
    get_user_posts: (username)->
        # @unblock()s
        console.log 'getting posts', username
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "https://www.reddit.com/u/#{username}.json"
        HTTP.get url,(err,res)=>
            # console.log res
            if res.data.data.dist > 0
                _.each(res.data.data.children[0..100], (item)=>
                    # console.log item
                    found = 
                        Docs.findOne    
                            model:'rpost'
                            reddit_id:item.data.id
                            # subreddit:item.data.id
                    # if found
                    #     console.log found, 'found'
                    unless found
                        # console.log found, 'not found'
                        item.model = 'rpost'
                        item.reddit_id = item.data.id
                        item.author = item.data.author
                        item.subreddit = item.data.subreddit
                        Docs.insert item
                )
    
    get_user_comments: (username)->
        # @unblock()s
        console.log 'getting comments', username
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "https://www.reddit.com/u/#{username}/comments.json"
        HTTP.get url,(err,res)=>
            # console.log res
            if res.data.data.dist > 0
                _.each(res.data.data.children[0..100], (item)=>
                    # console.log item
                    found = 
                        Docs.findOne    
                            model:'rcomment'
                            reddit_id:item.data.id
                            # subreddit:item.data.id
                    # if found
                    #     console.log found, 'found'
                    unless found
                        # console.log found, 'not found'
                        item.model = 'rcomment'
                        item.reddit_id = item.data.id
                        item.author = item.data.author
                        item.subreddit = item.data.subreddit
                        Docs.insert item
                )
        
            # for post in res.data.data.children
            #     existing = 
            #         Docs.findOne({
            #             reddit_id: post.data.id
            #             model:'rpost'
            #         })
            #     # continue
            #     unless existing
            #         console.log 'not existing'
            #     #     # if Meteor.isDevelopment
            #     #     # if typeof(existing.tags) is 'string'
            #     #     #     Doc.update
            #     #     #         $unset: tags: 1
            #     #     # Docs.update existing._id,
            #     #     #     $set: rdata:res.data.data
            #     #     continue
            #     # else
            #     #     console.log 'create', post.data.id
            #     #     # new_post = {}
            #     #     # new_post.model = 'reddit'
            #     #     # new_post.data = post.data
            #     #     # new_reddit_post_id = Docs.insert new_post
            #     #     continue

        
    get_user_info: (username)->
        # @unblock()s
        # console.log 'getting info', username
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "https://www.reddit.com/u/#{username}/about.json"
        # url = "https://www.reddit.com/u/hernannadal/about.json"
        options = {
            url: url
            headers: 
                # 'accept-encoding': 'gzip'
                "User-Agent": "web:com.dao.af:v1.2.3 (by /u/dontlisten65)"
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                # console.log parsed
                existing = Docs.findOne 
                    model:'ruser'
                    username:username
                if existing
                    # console.log 'existing', existing
                    Docs.update existing._id,
                        $set:   
                            data:parsed.data
                    # if Meteor.isDevelopment
                    # if typeof(existing.tags) is 'string'
                    # Docs.update existing._id,
                    #     $set: rdata:res.data.data
                unless existing
                    ruser = {}
                    ruser.model = 'ruser'
                    ruser.username = username
                    # ruser.rdata = res.data.data
                    new_reddit_post_id = Docs.insert ruser
            )).catch((err)->
                console.log err
            )
        
        # console.log 'url', url
        # HTTP.get url,(err,res)=>
        #     console.log res
        #     # if res.data.data

    # reddit_all: ->
    #     total = 
    #         Docs.find({
    #             model:'rpost'
    #             subreddit: $exists:false
    #         }, limit:100)
    #     total.forEach( (doc)->
    #     for doc in total.fetch()
    #         Meteor.call 'get_reddit_post', doc._id, doc.reddit_id, ->
    #     )


    get_reddit_post: (doc_id, reddit_id, root)->
        @unblock()
        doc = Docs.findOne doc_id
        if doc.reddit_id
            HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json&raw_json=1", (err,res)->
                if err then console.error err
                else
                    rd = res.data.data.children[0].data
                    # if rd.is_video
                    #     Meteor.call 'call_watson', doc_id, 'url', 'video', ->
                    # else if rd.is_image
                    #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                    # else
                    #     Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                    #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                    #     # Meteor.call 'call_visual', doc_id, ->
                    # if rd.selftext
                    #     unless rd.is_video
                    #         # if Meteor.isDevelopment
                    #         Docs.update doc_id, {
                    #             $set:
                    #                 body: rd.selftext
                    #         }, ->
                    #         #     Meteor.call 'pull_subreddit', doc_id, url
                    # if rd.selftext_html
                    #     unless rd.is_video
                    #         Docs.update doc_id, {
                    #             $set:
                    #                 html: rd.selftext_html
                    #         }, ->
                    #             # Meteor.call 'pull_subreddit', doc_id, url
                    # if rd.url
                    #     unless rd.is_video
                    #         url = rd.url
                    #         # if Meteor.isDevelopment
                    #         Docs.update doc_id, {
                    #             $set:
                    #                 reddit_url: url
                    #                 url: url
                    #         }, ->
                    #             # Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                    # update_ob = {}
                    # if rd.preview
                    #     if rd.preview.images[0].source.url
                    #         thumbnail = rd.preview.images[0].source.url
                    # else
                    #     thumbnail = rd.thumbnail
                    Docs.update doc_id,
                        $set:
                            data: rd
                            url: rd.url
                            # reddit_image:rd.preview.images[0].source.url
                            thumbnail: rd.thumbnail
                            subreddit: rd.subreddit
                            author: rd.author
                            domain: rd.domain
                            is_video: rd.is_video
                            ups: rd.ups
                            # downs: rd.downs
                            over_18: rd.over_18

                
    search_subreddit: (subreddit,search)->
        @unblock()
        # console.log 'searching', subreddit, 'for', search
        HTTP.get "http://reddit.com/r/#{subreddit}/search.json?q=#{search}&restrict_sr=1&include_over_18=on&raw_json=1&limit=20", (err,res)->
            if res.data.data.dist > 1
                _.each(res.data.data.children[0..100], (item)=>
                    # console.log item.data.id
                    found = 
                        Docs.findOne    
                            model:'rpost'
                            reddit_id:item.data.id
                            # subreddit:item.data.id
                    if found
                        # console.log found, 'found and updating', subreddit, found.data.title, search
                        Docs.update found._id, 
                            $addToSet: tags: $each: search
                            $set:
                                subreddit:item.data.subreddit
                    unless found
                        # console.log item.data.title, 'not found'
                        item.model = 'rpost'
                        item.reddit_id = item.data.id
                        item.author = item.data.author
                        item.group = item.data.subreddit
                        item.group_lowered = item.data.subreddit.toLowerCase()
                        item.subreddit = item.data.subreddit
                        item.tags = search
                        # item.rdata = item.data
                        Docs.insert item
                )
                
        
    tagify_time_rpost: (doc_id)->
        doc = Docs.findOne doc_id
        # moment.unix(doc.data.created).fromNow()
        # timestamp = Date.now()
        if doc.data and doc.data.created
            doc._timestamp_long = moment.unix(doc.data.created).format("dddd, MMMM Do YYYY, h:mm:ss a")
            # doc._app = 'dao'
        
            date = moment.unix(doc.data.created).format('Do')
            weekdaynum = moment.unix(doc.data.created).isoWeekday()
            weekday = moment().isoWeekday(weekdaynum).format('dddd')
        
            hour = moment.unix(doc.data.created).format('h')
            minute = moment.unix(doc.data.created).format('m')
            ap = moment.unix(doc.data.created).format('a')
            month = moment.unix(doc.data.created).format('MMMM')
            year = moment.unix(doc.data.created).format('YYYY')
        
            # doc.points = 0
            # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
            date_array = [ap, weekday, month, date, year]
            if _
                date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
                doc.timestamp_tags = date_array
                # console.log date_array
                Docs.update doc_id, 
                    $set:time_tags:date_array
                            

        
Meteor.publish 'related_posts', (post_id)->
    post = Docs.findOne post_id
    # console.log 'post tags', post.tags
        
    related_cur = 
        Docs.find({
            model:'rpost'
            subreddit:post.subreddit
            tags:$in:post.tags
            _id:$ne:post._id
        },{ 
            limit:10
            sort:"data.ups":-1
        })
    # console.log 'related count', related_cur.fetch()
    related_cur
    
Meteor.publish 'related_questions', (post_id)->
    post = Docs.findOne post_id
    # console.log 'post tags', post.tags
    if post
        related_cur = 
            Docs.find({
                model:'stack_question'
                tags:$in:post.tags
            },{ 
                limit:10
                sort:"score":-1
            })
        # console.log 'related count', related_cur.fetch()
        related_cur
            
Meteor.publish 'rpost_comments', (subreddit, doc_id)->
    post = Docs.findOne doc_id
    Docs.find
        model:'rcomment'
        parent_id:"t3_#{post.reddit_id}"
        
    
Meteor.publish 'agg_sentiment_subreddit', (
    subreddit
    picked_tags
    )->
    # @unblock()
    self = @
    match = {
        model:'rpost'
        group_lowered:subreddit.toLowerCase()
    }
        
    doc_count = Docs.find(match).count()
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    emotion_avgs = Docs.aggregate [
        { $match: match }
        #     # avgAmount: { $avg: { $multiply: [ "$price", "$quantity" ] } },
        { $group: 
            _id:null
            avg_sent_score: { $avg: "$doc_sentiment_score" }
            avg_joy_score: { $avg: "$joy_percent" }
            avg_anger_score: { $avg: "$anger_percent" }
            avg_sadness_score: { $avg: "$sadness_percent" }
            avg_disgust_score: { $avg: "$disgust_percent" }
            avg_fear_score: { $avg: "$fear_percent" }
        }
    ]
    emotion_avgs.forEach (res, i) ->
        self.added 'results', Random.id(),
            model:'emotion_avg'
            avg_sent_score: res.avg_sent_score
            avg_joy_score: res.avg_joy_score
            avg_anger_score: res.avg_anger_score
            avg_sadness_score: res.avg_sadness_score
            avg_disgust_score: res.avg_disgust_score
            avg_fear_score: res.avg_fear_score
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
            