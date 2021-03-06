request = require('request')
rp = require('request-promise');
Meteor.methods
    search_reddit: (query)->
        @unblock()
        # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "http://reddit.com/search.json?q=#{query}&limit=100&include_facets=false&raw_json=1&include_over_18=on"
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,res)=>
        HTTP.get url,(err,res)=>
            if res.data.data.dist > 1
                _.each(res.data.data.children, (item)=>
                    unless item.domain is "OneWordBan"
                        data = item.data
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
                            #     console.log 'existing', existing
                            # if typeof(existing.tags) is 'string'
                            #     Doc.update
                            #         $unset: tags: 1
                            Docs.update existing._id,
                                $addToSet: tags: $each: added_tags
                                $set:data:data

                            # Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
                        unless existing
                            new_reddit_post_id = Docs.insert reddit_post
                            # if Meteor.isDevelopment
                            #     console.log 'new', new_reddit_post_id
                            # Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                )
   

    get_reddit_post: (doc_id, reddit_id, root)->
        @unblock()
        doc = Docs.findOne doc_id
        if doc.reddit_id
            # HTTP.get "http://reddit.com/by_id/t3_#{doc.reddit_id}.json&raw_json=1", (err,res)->
            HTTP.get "https://www.reddit.com/comments/#{doc.reddit_id}/.json", (err,res)->
                if err
                    console.error err
                unless err
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

                


Meteor.methods
    # search_reddit: (query)->
    #     @unblock()
    #     # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
    #     # if subreddit 
    #     #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
    #     # else
    #     url = "http://reddit.com/search.json?q=#{query}&limit=30&include_facets=false&raw_json=1"
    #     # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,res)=>
    #     HTTP.get url,(err,res)=>
    #         if res.data.data.dist > 1
    #             _.each(res.data.data.children, (item)=>
    #                 unless item.domain is "OneWordBan"
    #                     data = item.data
    #                     len = 200
    #                     # if typeof(query) is String
    #                     #     added_tags = [query]
    #                     # else
    #                     added_tags = [query]
    #                     # added_tags = [query]
    #                     # added_tags.push data.domain.toLowerCase()
    #                     # added_tags.push data.subreddit.toLowerCase()
    #                     # added_tags.push data.author.toLowerCase()
    #                     added_tags = _.flatten(added_tags)
    #                     reddit_post =
    #                         reddit_id: data.id
    #                         url: data.url
    #                         domain: data.domain
    #                         comment_count: data.num_comments
    #                         permalink: data.permalink
    #                         ups: data.ups
    #                         title: data.title
    #                         subreddit: data.subreddit
    #                         # root: query
    #                         # selftext: false
    #                         # thumbnail: false
    #                         tags: added_tags
    #                         model:'reddit'
    #                         # source:'reddit'
    #                     existing = Docs.findOne 
    #                         model:'reddit'
    #                         url:data.url
    #                     if existing
    #                         # if Meteor.isDevelopment
    #                         # if typeof(existing.tags) is 'string'
    #                         #     Doc.update
    #                         #         $unset: tags: 1
    #                         Docs.update existing._id,
    #                             $addToSet: tags: $each: added_tags

    #                         Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
    #                     unless existing
    #                         # if Meteor.isDevelopment
    #                         new_reddit_post_id = Docs.insert reddit_post
    #                         # Meteor.users.update Meteor.userId(),
    #                         #     $inc:points:1
    #                         Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
    #             )
   
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
                            # if Meteor.isDevelopment
                            # Meteor.users.update Meteor.userId(),
                            #     $inc:points:1
                            Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                )
    
    reddit_new: (query)->
        @unblock()
        
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
                            # if Meteor.isDevelopment
        
                            # Meteor.users.update Meteor.userId(),
                            #     $inc:points:1
                            Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                )
    
            
    get_post_comments: (subreddit, doc_id)->
        @unblock()
        doc = Docs.findOne doc_id
        
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        # https://www.reddit.com/r/uwo/comments/fhnl8k/ontario_to_close_all_public_schools_for_two_weeks.json
        url = "https://www.reddit.com/r/#{subreddit}/comments/#{doc.reddit_id}.json?&raw_json=1&nsfw=1"
        HTTP.get url,(err,res)=>
            # if res.data.data.dist > 1
            # [1].data.children[0].data.body
            _.each(res.data[1].data.children[0..100], (item)=>
                found = 
                    Docs.findOne    
                        model:'rcomment'
                        reddit_id:item.data.id
                        parent_id:item.data.parent_id
                        # subreddit:item.data.id
                # if found
                #     # Docs.update found._id,
                #     #     $set:subreddit:item.data.subreddit
                unless found
                    item.model = 'rcomment'
                    item.reddit_id = item.data.id
                    item.parent_id = item.data.parent_id
                    item.subreddit = subreddit
                    Docs.insert item
            )
    
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


    # get_reddit_post: (doc_id, reddit_id, root)->
    #     @unblock()
    #     doc = Docs.findOne doc_id
    #     if doc.reddit_id
    #         HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json&raw_json=1", (err,res)->
    #             if err then console.error err
    #             else
    #                 rd = res.data.data.children[0].data
    #                 # if rd.is_video
    #                 #     Meteor.call 'call_watson', doc_id, 'url', 'video', ->
    #                 # else if rd.is_image
    #                 #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
    #                 # else
    #                 #     Meteor.call 'call_watson', doc_id, 'url', 'url', ->
    #                 #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
    #                 #     # Meteor.call 'call_visual', doc_id, ->
    #                 # if rd.selftext
    #                 #     unless rd.is_video
    #                 #         # if Meteor.isDevelopment
    #                 #         Docs.update doc_id, {
    #                 #             $set:
    #                 #                 body: rd.selftext
    #                 #         }, ->
    #                 #         #     Meteor.call 'pull_subreddit', doc_id, url
    #                 # if rd.selftext_html
    #                 #     unless rd.is_video
    #                 #         Docs.update doc_id, {
    #                 #             $set:
    #                 #                 html: rd.selftext_html
    #                 #         }, ->
    #                 #             # Meteor.call 'pull_subreddit', doc_id, url
    #                 # if rd.url
    #                 #     unless rd.is_video
    #                 #         url = rd.url
    #                 #         # if Meteor.isDevelopment
    #                 #         Docs.update doc_id, {
    #                 #             $set:
    #                 #                 reddit_url: url
    #                 #                 url: url
    #                 #         }, ->
    #                 #             # Meteor.call 'call_watson', doc_id, 'url', 'url', ->
    #                 # update_ob = {}
    #                 # if rd.preview
    #                 #     if rd.preview.images[0].source.url
    #                 #         thumbnail = rd.preview.images[0].source.url
    #                 # else
    #                 #     thumbnail = rd.thumbnail
    #                 Docs.update doc_id,
    #                     $set:
    #                         data: rd
    #                         url: rd.url
    #                         # reddit_image:rd.preview.images[0].source.url
    #                         thumbnail: rd.thumbnail
    #                         subreddit: rd.subreddit
    #                         author: rd.author
    #                         domain: rd.domain
    #                         is_video: rd.is_video
    #                         ups: rd.ups
    #                         # downs: rd.downs
    #                         over_18: rd.over_18

        
