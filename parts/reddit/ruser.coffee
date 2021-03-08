if Meteor.isClient
    Router.route '/ruser/:username', (->
        @layout 'layout'
        @render 'ruser'
        ), name:'ruser'

   
    Template.ruser.onCreated ->
        @autorun => Meteor.subscribe 'ruser_doc', Router.current().params.username
        @autorun => Meteor.subscribe 'ruser_posts', Router.current().params.username, 42
        @autorun => Meteor.subscribe 'ruser_comments', Router.current().params.username
        @autorun => Meteor.subscribe 'ruser_result_tags',
            'rpost'
            Router.current().params.username
            picked_sub_tags.array()
            # selected_subreddit_domain.array()
            Session.get('toggle')
        @autorun => Meteor.subscribe 'ruser_result_tags',
            'rcomment'
            Router.current().params.username
            picked_sub_tags.array()
            # selected_subreddit_domain.array()
            Session.get('toggle')

    Template.ruser.onRendered ->
        Meteor.call 'get_user_comments', Router.current().params.username, ->
        Meteor.setTimeout =>
            Meteor.call 'get_user_info', Router.current().params.username, ->
                Meteor.call 'get_user_posts', Router.current().params.username, ->
                    Meteor.call 'ruser_omega', Router.current().params.username, ->
                        Meteor.call 'rank_ruser', Router.current().params.username, ->
        , 2000

    Template.ruser_doc_item.onRendered ->
        # console.log @
        unless @data.watson
            Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
 
    Template.ruser_comment.events
        'click .call_watson_comment': ->
            console.log 'call', 
            Meteor.call 'call_watson', @_id,'data.body','comment',->
            
    Template.ruser_comment.onRendered ->
        unless @data.watson
            # console.log 'calling watson on comment'
            Meteor.call 'call_watson', @data._id,'data.body','comment',->
    Template.ruser_post.onRendered ->
        unless @data.watson
            # console.log 'calling watson on comment'
            Meteor.call 'call_watson', @data._id,'data.body','comment',->

    Template.ruser.helpers
        ruser_doc: ->
            Docs.findOne
                model:'ruser'
                username:Router.current().params.username
        ruser_posts: ->
            Docs.find {
                model:'rpost'
                author:Router.current().params.username
            },{
                limit:20
                sort:
                    _timestamp:-1
            }  
        ruser_comments: ->
            Docs.find
                model:'rcomment'
                author:Router.current().params.username
            , limit:20

        ruser_post_tag_results: -> results.find(model:'rpost_result_tag')
        ruser_comment_tag_results: -> results.find(model:'rcomment_result_tag')
    Template.ruser.events
        'click .get_user_info': ->
            Meteor.call 'get_user_info', Router.current().params.username, ->
        'click .search_tag': -> 
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            picked_ruser_tags.clear()
            picked_ruser_tags.push @valueOf()
            Router.go "/rusers"

        'click .get_user_posts': ->
            Meteor.call 'get_user_posts', Router.current().params.username, ->
            Meteor.call 'ruser_omega', Router.current().params.username, ->
            Meteor.call 'rank_ruser', Router.current().params.username, ->

        'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
        'click .toggle_question_detail': (e,t)-> Session.set('view_question_detail',!Session.get('view_question_detail'))

        'click .search': ->
            # window.speechSynthesis.speak new SpeechSynthesisUtterance "import #{Router.current().params.username}"
            Meteor.call 'search_ruser', Router.current().params.username, ->
        

    
if Meteor.isServer
    Meteor.publish 'ruser_doc', (username)->
        match = {
            model:'ruser'
            username:username
        }
        unless Meteor.isDevelopment
            match.data.subreddit.over_18 = false 
        Docs.find match
    
    Meteor.publish 'ruser_posts', (username, limit=42)->
        match = {
            model:'rpost'
            author:username
        }
        unless Meteor.isDevelopment
            match.over_18 = false 
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
    Meteor.publish 'ruser_comments', (username, limit=42)->
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
if Meteor.isServer
    request = require('request')
    rp = require('request-promise');
    
    Meteor.methods
        get_user_posts: (username)->
            # @unblock()s
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
            # @unblock()s
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
                            console.log 'creating new user comment', item.data.body
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
            # @unblock()s
            # if subreddit 
            #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
            # else
            url = "https://www.reddit.com/user/#{username}/about.json"
            # url = "https://www.reddit.com/user/hernannadal/about.json"
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
                    existing = Docs.findOne 
                        model:'ruser'
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
                        ruser = {}
                        ruser.model = 'ruser'
                        ruser.username = username
                        # ruser.rdata = res.data.data
                        new_reddit_post_id = Docs.insert ruser
                )).catch((err)->
                )
            
            # HTTP.get url,(err,res)=>
            #     # if res.data.data
    