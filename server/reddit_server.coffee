Meteor.methods
    search_reddit: (query, subreddit)->
        @unblock()
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "http://reddit.com/search.json?q=#{query}&nsfw=1&limit=5&include_facets=false"
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        HTTP.get url,(err,response)=>
            if response.data.data.dist > 1
                _.each(response.data.data.children, (item)=>
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
                        existing_doc = Docs.findOne 
                            model:'reddit'
                            url:data.url
                        if existing_doc
                            # if Meteor.isDevelopment
                            # if typeof(existing_doc.tags) is 'string'
                            #     Doc.update
                            #         $unset: tags: 1
                            Docs.update existing_doc._id,
                                $addToSet: tags: $each: added_tags

                            Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                        unless existing_doc
                            new_reddit_post_id = Docs.insert reddit_post
                            # Meteor.users.update Meteor.userId(),
                            #     $inc:points:1
                            Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                    else
                )

        # _.each(response.data.data.children, (item)->
        #     # data = item.data
        #     # len = 200
        # )

    reddit_all: ->
        total = 
            Docs.find({
                model:'reddit'
                subreddit: $exists:false
            }, limit:100)
        total.forEach( (doc)->
        for doc in total.fetch()
            Meteor.call 'get_reddit_post', doc._id, doc.reddit_id, ->
        )
        


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
                _.each(res.data.data.children[0..100], (item)=>
                    found = 
                        Docs.findOne    
                            model:'subreddit'
                            "data.display_name":item.data.display_name
                    # if found
                    unless found
                        item.model = 'subreddit'
                        Docs.insert item
                )
                
                
                
Meteor.publish 'stack_sites', (selected_tags=[], name_filter='')->
    match = {model:$in:['stack_site','tribe']}
    match.site_type = 'main_site'
    if selected_tags.length > 0
        match.tags = $all: selected_tags
    if name_filter.length > 0
        match.name = {$regex:"#{name_filter}", $options:'i'}
    Docs.find match,
        limit:300
Meteor.publish 'stack_sites_small', (selected_tags=[], name_filter='')->
    match = {model:$in:['stack_site','tribe']}
    match.site_type = 'main_site'
    if selected_tags.length > 0
        match.tags = $all: selected_tags
    if name_filter.length > 0
        match.name = {$regex:"#{name_filter}", $options:'i'}
    Docs.find match,
        {
            limit:500
            fields:
                audience:1
                logo_url:1
                name:1
                model:1
                api_site_parameter:1
                styling:1
        }

Meteor.publish 'question_answers', (question_doc_id)->
    question = Docs.findOne question_doc_id
    Docs.find 
        model:'stack_answer'
        site:question.site
        question_id:question.question_id

Meteor.publish 'stackuser_doc', (site,user_id)->
    Docs.find 
        model:'stackuser'
        user_id:parseInt(user_id)
        site:site

Meteor.publish 'site_by_param', (site)->
    Docs.find 
        model:'stack_site'
        api_site_parameter:site

# Meteor.publish 'stack_docs', ->
#     Docs.find {
#         model:'stack'
#     },
#         limit:20
        
                        
            