request = require('request')
rp = require('request-promise');


Meteor.methods
    search_reddit: (query, subreddit)->
        @unblock()
        # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "http://reddit.com/search.json?q=#{query}&nsfw=0&limit=5&include_facets=false"
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
        url = "https://www.reddit.com/r/#{subreddit}/about.json?"
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
    
    
    get_user_posts: (username)->
        # @unblock()s
        console.log 'getting info', username
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "https://www.reddit.com/user/#{username}.json"
        HTTP.get url,(err,res)=>
            # console.log res.data.data.children.length
            # if res.data.data.dist > 1
            _.each(res.data.data.children[0..2], (item)=>
                console.log item.data.id
                found = 
                    Docs.findOne    
                        model:'rpost'
                        reddit_id:item.data.id
                        # subreddit:item.data.id
                if found
                    console.log found, 'found'
                unless found
                    console.log found, 'not found'
                    item.model = 'rpost'
                    item.reddit_id = item.data.id
                    # item.rdata = item.data
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
            HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json", (err,res)->
                if err then console.error err
                else
                    rd = res.data.data.children[0].data
                    result =
                        Docs.update doc_id,
                            $set:
                                rd: rd
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
                    #         #     Meteor.call 'pull_site', doc_id, url
                    # if rd.selftext_html
                    #     unless rd.is_video
                    #         Docs.update doc_id, {
                    #             $set:
                    #                 html: rd.selftext_html
                    #         }, ->
                    #             # Meteor.call 'pull_site', doc_id, url
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
                            rd: rd
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
                        # $addToSet:
                        #     tags: $each: [rd.subreddit.toLowerCase()]



    search_subreddits: (search)->
        @unblock()
        HTTP.get "http://reddit.com/subreddits/search.json?q=#{search}", (err,res)->
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
        match["rdata.display_name"] = {$regex:"#{query}", $options:'i'}
    Docs.find match,
        limit:20
        
Meteor.publish 'rposts', (name)->
    Docs.find
        model:'rpost'
Meteor.publish 'sub_docs_by_name', (name)->
    Docs.find {
        model:'reddit'
        subreddit:name
    }, limit:20
Meteor.methods 
    log_subreddit_view: (name)->
        sub = Docs.findOne
            model:'subreddit'
            "rdata.display_name":name
        if sub
            Docs.update sub._id,
                $inc:dao_views:1