request = require('request')
rp = require('request-promise');



Meteor.publish 'user_posts', (username, limit=20)->
    match = {
        model:'rpost'
        author:username
    }
    @unblock()
    # unless Meteor.isDevelopment
    # match.over_18 = false 
    Docs.find match,{
        limit:limit
        sort:
            _timestamp:-1
        fields:
            "data.ups":1
            "data.title":1
            "data.created":1
            "data.body":1
            "tags":1
            "data.subreddit":1
            "model":1
            "author":1
            doc_sentiment_score:1
            doc_sentiment_label:1
            joy_percent:1
            sadness_percent:1
            fear_percent:1
            disgust_percent:1
            anger_percent:1
            "watson.metadata":1
            "data.thumbnail":1
            "data.url":1
            max_emotion_name:1
            max_emotion_percent:1
    }  
Meteor.publish 'user_comments', (username, limit=20)->
    @unblock()
    
    Docs.find
        model:'rcomment'
        author:username
    , {
        limit:limit
        fields:
            "data.score":1
            "data.created":1
            "data.body":1
            "tags":1
            "data.subreddit":1
            "model":1
            "author":1
            doc_sentiment_score:1
            doc_sentiment_label:1
            joy_percent:1
            sadness_percent:1
            max_emotion_name:1
            fear_percent:1
            disgust_percent:1
            anger_percent:1
    }

Meteor.methods
    get_user_posts: (username)->
        @unblock()
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "https://www.reddit.com/user/#{username}.json"
        HTTP.get url,(err,res)=>
            if res.data.data.dist > 0
                _.each(res.data.data.children[0..100], (item)=>
                    found = 
                        Docs.findOne    
                            model:'rpost'
                            reddit_id:item.data.id
                            # subreddit:item.data.id
                    # if found
                    unless found
                        item.model = 'rpost'
                        item.reddit_id = item.data.id
                        item.author = item.data.author
                        item.subreddit = item.data.subreddit
                        Docs.insert item
                )
    
    get_user_comments: (username)->
        @unblock()
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "https://www.reddit.com/user/#{username}/comments.json"
        HTTP.get url,(err,res)=>
            if res.data.data.dist > 0
                _.each(res.data.data.children[0..100], (item)=>
                    found = 
                        Docs.findOne    
                            model:'rcomment'
                            reddit_id:item.data.id
                            # subreddit:item.data.id
                    # if found
                    #     console.log 'found user comment', found.data.body
                        
                    unless found
                        # console.log 'creating new user comment', item.data.body
                        item.model = 'rcomment'
                        item.reddit_id = item.data.id
                        item.author = item.data.author
                        item.subreddit = item.data.subreddit
                        Docs.insert item, ->
                )
        
            # for post in res.data.data.children
            #     existing = 
            #         Docs.findOne({
            #             reddit_id: post.data.id
            #             model:'reddit'
            #         })
            #     # continue
            #     unless existing
            #     #     # if Meteor.isDevelopment
            #     #     # if typeof(existing.tags) is 'string'
            #     #     #     Doc.update
            #     #     #         $unset: tags: 1
            #     #     # Docs.update existing._id,
            #     #     #     $set: rdata:res.data.data
            #     #     continue
            #     # else
            #     #     # new_post = {}
            #     #     # new_post.model = 'reddit'
            #     #     # new_post.data = post.data
            #     #     # new_reddit_post_id = Docs.insert new_post
            #     #     continue

        
    get_user_info: (username)->
        @unblock()
        # if subreddit 
        #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
        # else
        url = "https://www.reddit.com/user/#{username}/about.json"
        # url = "https://www.reddit.com/user/hernannadal/about.json"
        options = {
            url: url
            headers: 
                # 'accept-encoding': 'gzip'
                "User-Agent": "web:com.dao.af:v1.2.3 (by /u/dao-af)"
            gzip: true
        }
        rp(options)
            .then(Meteor.bindEnvironment((data)->
                parsed = JSON.parse(data)
                existing = Docs.findOne 
                    model:'user'
                    username:username
                if existing
                    Docs.update existing._id,
                        $set:   
                            data:parsed.data
                    # if Meteor.isDevelopment
                    # if typeof(existing.tags) is 'string'
                    # Docs.update existing._id,
                    #     $set: rdata:res.data.data
                unless existing
                    user = {}
                    user.model = 'user'
                    user.username = username
                    # user.rdata = res.data.data
                    new_reddit_post_id = Docs.insert user
            )).catch((err)->
            )
        
        # HTTP.get url,(err,res)=>
        #     # if res.data.data
