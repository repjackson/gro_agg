request = require('request')
rp = require('request-promise');


Meteor.methods
    remove_doc: (doc_id)->
        Docs.remove doc_id
    get_post_comments: (subreddit, doc_id)->
        @unblock()
        console.log 'getting post comments', subreddit, doc_id
        doc = Docs.findOne doc_id
        console.log 'getting comments'
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


        
    search_reddit: (query)->
        console.log 'searching reddit'
        @unblock()
        # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "http://reddit.com/search.json?q=#{query}&limit=100&include_facets=false&raw_json=1&nsfw=1&include_over_18=on"
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
                        existing = Docs.findOne 
                            model:'rpost'
                            url:data.url
                        if existing
                            # if Meteor.isDevelopment
                            #     console.log 'new search doc', data.title
                            # if typeof(existing.tags) is 'string'
                            #     Doc.update
                            #         $unset: tags: 1
                            Docs.update({_id:existing._id},{
                                $addToSet: tags: $each: added_tags
                                $set:
                                    data:data
                                    points:data.ups
                            }, (res)-> console.log res)
                            Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
                        unless existing
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
                            # if Meteor.isDevelopment
                            #     console.log 'new search doc', reddit_post.title
                            timestamp = Date.now()
                            reddit_post._timestamp = timestamp
                            reddit_post._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
                            # doc._app = 'dao'
                            # if Meteor.user()
                            #     doc._author_id = Meteor.userId()
                            #     doc._author_username = Meteor.user().username
                        
                            # date = moment(timestamp).format('Do')
                            # weekdaynum = moment(timestamp).isoWeekday()
                            # weekday = moment().isoWeekday(weekdaynum).format('dddd')
                        
                            # hour = moment(timestamp).format('h')
                            # minute = moment(timestamp).format('m')
                            # ap = moment(timestamp).format('a')
                            # month = moment(timestamp).format('MMMM')
                            # year = moment(timestamp).format('YYYY')
                        
                            # # doc.points = 0
                            # # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
                            # date_array = [ap, weekday, month, date, year]
                            # if _
                            #     date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
                            #     reddit_post.timestamp_tags = date_array
                            new_reddit_post_id = Docs.insert reddit_post
                            Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                )
   

    get_reddit_post: (doc_id, reddit_id, root)->
        @unblock()
        doc = Docs.findOne doc_id
        if doc.reddit_id
            # HTTP.get "http://reddit.com/by_id/t3_#{doc.reddit_id}.json&raw_json=1", (err,res)->
            HTTP.get "https://www.reddit.com/comments/#{doc.reddit_id}/.json&raw_json=1&nsfw=1&include_over_18=on", (err,res)->
                if err
                    console.log 'error getting', doc.reddit_id
                    # console.error err
                unless err
                    # console.log res.data[0].data.children[0].data
                    if res.data
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
                    # else 
                    #     console.log res
        
        
        
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
    #             model:'reddit'
    #             subreddit: $exists:false
    #         }, limit:100)
    #     total.forEach( (doc)->
    #     for doc in total.fetch()
    #         Meteor.call 'get_reddit_post', doc._id, doc.reddit_id, ->
    #     )

        
    search_subreddits: (search)->
        @unblock()
        HTTP.get "http://reddit.com/subreddits/search.json?q=#{search}&raw_json=1&nsfw=1&include_over_18=on", (err,res)->
            if res.data.data.dist > 1
                _.each(res.data.data.children[0..200], (item)=>
                    found = 
                        Docs.findOne    
                            model:'subreddit'
                            "data.display_name":item.data.display_name
                    if found
                        console.log 'found', search, item.data.display_name
                        Docs.update found._id, 
                            $addToSet:
                                tags:search.toLowerCase()
                    unless found
                        console.log 'not found', item.data.display_name
                        item.model = 'subreddit'
                        item.tags = [search.toLowerCase()]
                        Docs.insert item
                        
                )
        