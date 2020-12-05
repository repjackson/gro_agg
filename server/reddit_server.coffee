request = require('request')
rp = require('request-promise');


Meteor.methods
    search_reddit: (query, subreddit)->
        @unblock()
        # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "http://reddit.com/search.json?q=#{query}&nsfw=1&limit=100&include_facets=true&raw_json=1"
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
                            model:'reddit'
                            # source:'reddit'
                        existing = Docs.findOne 
                            model:'reddit'
                            url:data.url
                        if existing
                            # if Meteor.isDevelopment
                            # if typeof(existing.tags) is 'string'
                            #     Doc.update
                            #         $unset: tags: 1
                            Docs.update existing._id,
                                $addToSet: tags: $each: added_tags

                            Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
                        unless existing
                            new_reddit_post_id = Docs.insert reddit_post
                            # Meteor.users.update Meteor.userId(),
                            #     $inc:points:1
                            Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                )
    
    get_sub_info: (subreddit)->
        @unblock()
        console.log 'getting info', subreddit
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "https://www.reddit.com/r/#{subreddit}/about.json?&raw_json=1"
        HTTP.get url,(err,res)=>
            # console.log res.data.data
            if res.data.data
                existing = Docs.findOne 
                    model:'subreddit'
                    name:subreddit
                if existing
                    console.log 'existing', existing
                    # if Meteor.isDevelopment
                    # if typeof(existing.tags) is 'string'
                    #     Doc.update
                    #         $unset: tags: 1
                    Docs.update existing._id,
                        $set: rdata:res.data.data
                unless existing
                    sub = {}
                    sub.model = 'subreddit'
                    sub.name = subreddit
                    sub.rdata = res.data.data
                    new_reddit_post_id = Docs.insert sub
    
    get_sub_latest: (subreddit)->
        @unblock()
        console.log 'getting latest', subreddit
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
    
    get_user_posts: (username)->
        # @unblock()s
        console.log 'getting info', username
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "https://www.reddit.com/user/#{username}.json"
        HTTP.get url,(err,res)=>
            if res.data.data.dist > 1
                _.each(res.data.data.children[0..100], (item)=>
                    console.log item
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
        
            # for post in res.data.data.children
            #     existing = 
            #         Docs.findOne({
            #             reddit_id: post.data.id
            #             model:'reddit'
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
        console.log 'getting info', username
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        # url = "https://www.reddit.com/user/#{username}/about.json"
        # options = {
        #     url: url
        #     headers: 'accept-encoding': 'gzip'
        #     gzip: true
        # }
        # rp(options)
        #     .then(Meteor.bindEnvironment((data)->
        #         parsed = JSON.parse(data)
        #         console.log parsed
        #     )).catch((err)->
        #         console.log "ERR", err
        #     )

        # console.log 'url', url
        # HTTP.get url,(err,res)=>
        #     console.log res
        #     # if res.data.data
        existing = Docs.findOne 
            model:'ruser'
            username:username
        if existing
            console.log 'existing', existing
            # if Meteor.isDevelopment
            # if typeof(existing.tags) is 'string'
            #     Doc.update
            #         $unset: tags: 1
            # Docs.update existing._id,
            #     $set: rdata:res.data.data
        unless existing
            ruser = {}
            ruser.model = 'ruser'
            ruser.username = username
            # ruser.rdata = res.data.data
            new_reddit_post_id = Docs.insert ruser

    # reddit_all: ->
    #     total = 
    #         Docs.find({
    #             model:'reddit'
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

    search_subreddits: (search)->
        @unblock()
        HTTP.get "http://reddit.com/subreddits/search.json?q=#{search}&raw_json=1&nsfw=1", (err,res)->
            if res.data.data.dist > 1
                _.each(res.data.data.children[0..200], (item)=>
                    found = 
                        Docs.findOne    
                            model:'subreddit'
                            "rdata.display_name":item.data.display_name
                    # if found
                    unless found
                        item.model = 'subreddit'
                        Docs.insert item
                )
                
    search_subreddit: (subreddit,search)->
        @unblock()
        console.log 'searching ', subreddit, 'for ', search
        HTTP.get "http://reddit.com/r/#{subreddit}/search.json?q=#{search}&restrict_sr=1&raw_json=1&nsfw=1", (err,res)->
            if res.data.data.dist > 1
                _.each(res.data.data.children[0..100], (item)=>
                    # console.log item.data.id
                    found = 
                        Docs.findOne    
                            model:'rpost'
                            reddit_id:item.data.id
                            # subreddit:item.data.id
                    if found
                        console.log found, 'found and updating', subreddit
                        Docs.update found._id, 
                            $addToSet: tags: search
                            # $set:
                            #     subreddit:item.data.subreddit
                    unless found
                        # console.log found, 'not found'
                        item.model = 'rpost'
                        item.reddit_id = item.data.id
                        item.author = item.data.author
                        item.subreddit = item.data.subreddit
                        item.tags = [search]
                        # item.rdata = item.data
                        Docs.insert item
                )
                
                
                        

Meteor.publish 'subreddit_by_param', (name)->
    Docs.find
        model:'subreddit'
        name:name
        
Meteor.publish 'subreddits', (
    query=''
    selected_tags
    )->
    match = {model:'subreddit'}
    
    if query.length > 0
        match["data.display_name"] = {$regex:"#{query}", $options:'i'}
    Docs.find match,
        limit:100
        
Meteor.publish 'rposts', (username)->
    Docs.find
        model:'rpost'
        author:username
Meteor.publish 'sub_docs_by_name', (
    subreddit
    selected_tags
    )->
    self = @
    match = {
        model:'rpost'
        subreddit:subreddit
    }
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    if selected_tags.length > 0 then match.tags = $all:selected_tags
    
    Docs.find match,
        limit:30
    
    
Meteor.publish 'agg_sentiment_subreddit', (
    subreddit
    selected_tags
    )->
    # @unblock()
    self = @
    match = {
        model:'rpost'
        subreddit:subreddit
    }
        
    doc_count = Docs.find(match).count()
    if selected_tags.length > 0 then match.tags = $all:selected_tags
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
    

Meteor.publish 'sub_doc_count', (
    subreddit
    selected_tags
    )->
        
    match = {model:'rpost'}
    match.subreddit = subreddit
    if selected_tags.length > 0 then match.tags = $all:selected_tags
    Counts.publish this, 'sub_doc_counter', Docs.find(match)
    return undefined



Meteor.publish 'subreddit_tags', (
    subreddit
    selected_tags
    # view_bounties
    # view_unanswered
    # query=''
    )->
    # @unblock()
    self = @
    match = {
        model:'rpost'
        subreddit:subreddit
        }
    # if view_bounties
    #     match.bounty = true
    # if view_unanswered
    #     match.is_answered = false
    if selected_tags.length > 0 then match.tags = $all:selected_tags
    # if selected_emotion.length > 0 then match.max_emotion_name = selected_emotion
    doc_count = Docs.find(match).count()
    # console.log 'doc_count', doc_count
    subreddit_tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $match: count: $lt: doc_count }
        { $limit:10 }
        { $project: _id: 0, name: '$_id', count: 1 }
    ]
    subreddit_tag_cloud.forEach (tag, i) ->
        self.added 'results', Random.id(),
            name: tag.name
            count: tag.count
            model:'subreddit_tag'
    
    
    # subreddit_Location_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "Location": 1 }
    #     { $unwind: "$Location" }
    #     { $group: _id: "$Location", count: $sum: 1 }
    #     # { $match: _id: $nin: selected_Locations }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:7 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # subreddit_Location_cloud.forEach (Location, i) ->
    #     self.added 'results', Random.id(),
    #         name: Location.name
    #         count: Location.count
    #         model:'subreddit_Location'
  
  
    # subreddit_Organization_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "Organization": 1 }
    #     { $unwind: "$Organization" }
    #     { $group: _id: "$Organization", count: $sum: 1 }
    #     # { $match: _id: $nin: selected_Organizations }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:5 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # subreddit_Organization_cloud.forEach (Organization, i) ->
    #     self.added 'results', Random.id(),
    #         name: Organization.name
    #         count: Organization.count
    #         model:'subreddit_Organization'
  
  
    # subreddit_Person_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "Person": 1 }
    #     { $unwind: "$Person" }
    #     { $group: _id: "$Person", count: $sum: 1 }
    #     # { $match: _id: $nin: selected_Persons }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:5 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # subreddit_Person_cloud.forEach (Person, i) ->
    #     self.added 'results', Random.id(),
    #         name: Person.name
    #         count: Person.count
    #         model:'subreddit_Person'
  
  
    # subreddit_Company_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "Company": 1 }
    #     { $unwind: "$Company" }
    #     { $group: _id: "$Company", count: $sum: 1 }
    #     # { $match: _id: $nin: selected_Companys }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:5 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # subreddit_Company_cloud.forEach (Company, i) ->
    #     self.added 'results', Random.id(),
    #         name: Company.name
    #         count: Company.count
    #         model:'subreddit_Company'
  
  
    # subreddit_emotion_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: "max_emotion_name": 1 }
    #     { $group: _id: "$max_emotion_name", count: $sum: 1 }
    #     # { $match: _id: $nin: selected_emotions }
    #     { $sort: count: -1, _id: 1 }
    #     { $match: count: $lt: doc_count }
    #     { $limit:5 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    # ]
    # subreddit_emotion_cloud.forEach (emotion, i) ->
    #     self.added 'results', Random.id(),
    #         name: emotion.name
    #         count: emotion.count
    #         model:'subreddit_emotion'
  
  
    self.ready()

    
Meteor.methods 
    log_subreddit_view: (name)->
        sub = Docs.findOne
            model:'subreddit'
            "rdata.display_name":name
        if sub
            Docs.update sub._id,
                $inc:dao_views:1