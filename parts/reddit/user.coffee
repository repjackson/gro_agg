if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'layout'
        @render 'user'
        ), name:'user'

   
    Template.user.onCreated ->
        @autorun => Meteor.subscribe 'user_doc', Router.current().params.username, ->
    Template.user_posts.onCreated ->
        @autorun => Meteor.subscribe 'user_posts', Router.current().params.username, 42, ->
    Template.user_comments.onCreated ->
        @autorun => Meteor.subscribe 'user_comments', Router.current().params.username, ->
    Template.user_comments.onCreated ->
        # @autorun => Meteor.subscribe 'user_result_tags',
        #     'rpost'
        #     Router.current().params.username
        #     picked_sub_tags.array()
        #     # selected_subreddit_domain.array()
        #     Session.get('toggle')
        # , ->
        # @autorun => Meteor.subscribe 'user_result_tags',
        #     'rcomment'
        #     Router.current().params.username
        #     picked_sub_tags.array()
        #     # selected_subreddit_domain.array()
        #     Session.get('toggle')
        # , ->

    Template.user.onRendered ->
        # Meteor.setTimeout =>
        $('body').toast(
            showIcon: 'user'
            message: 'getting user info'
            displayTime: 'auto',
        )
        Meteor.call 'get_user_info', Router.current().params.username, ->
            $('body').toast(
                message: 'info retrieved'
                showIcon: 'user'
                showProgress: 'bottom'
                class: 'info'
                displayTime: 'auto',
            )
            Session.set('thinking',false)
    Template.user_comments.onRendered ->
        $('body').toast(
            showIcon: 'chat'
            message: 'getting comments'
            displayTime: 'auto',
        )
        Meteor.call 'get_user_comments', Router.current().params.username, ->
            $('body').toast(
                message: 'comments done'
                showIcon: 'chat'
                showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
            )
            Session.set('thinking',false)

          
        Meteor.setTimeout =>
            $('body').toast(
                showIcon: 'dna'
                message: 'calculating stats'
                displayTime: 'auto',
            )
            Meteor.call 'user_omega', Router.current().params.username, ->
                $('body').toast(
                    message: 'stats calculated'
                    showIcon: 'dna'
                    showProgress: 'bottom'
                    class: 'success'
                    displayTime: 'auto',
                )
                Session.set('thinking',false)
           
           
            $('body').toast(
                showIcon: 'line chart'
                message: 'ranking user'
                displayTime: 'auto',
            )
            Meteor.call 'rank_user', Router.current().params.username, ->
                $('body').toast(
                    message: 'user ranked'
                    showIcon: 'line chart'
                    showProgress: 'bottom'
                    class: 'success'
                    displayTime: 'auto',
                )
                Session.set('thinking',false)
        , 10000

    Template.user_doc_item.onRendered ->
        # console.log @
        unless @data.watson
            Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
 
    Template.user_comment.events
        'click .call_watson_comment': ->
            console.log 'call', 
            Meteor.call 'call_watson', @_id,'data.body','comment',->
            
    Template.user_comment.onRendered ->
        unless @data.watson
            # console.log 'calling watson on comment'
            Meteor.call 'call_watson', @data._id,'data.body','comment',->
    Template.user_post.onRendered ->
        unless @data.watson
            # console.log 'calling watson on comment'
            Meteor.call 'call_watson', @data._id,'data.body','comment',->

    Template.user.helpers
        user_doc: ->
            Docs.findOne
                model:'user'
                username:Router.current().params.username
        current_username: -> Router.current().params.username
        user_post_tag_results: -> results.find(model:'rpost_result_tag')
        user_comment_tag_results: -> results.find(model:'rcomment_result_tag')
    Template.user_posts.events
        'click .refresh_posts': ->
            $('body').toast(
                showIcon: 'edit'
                message: 'getting user posts'
                displayTime: 'auto',
            )
            Meteor.call 'get_user_posts', Router.current().params.username, ->
                $('body').toast(
                    message: 'posts downloaded'
                    showIcon: 'user'
                    showProgress: 'bottom'
                    class: 'success'
                    displayTime: 'auto',
                )
                Session.set('thinking',false)
          
    Template.user_posts.onRendered ->
        $('body').toast(
            showIcon: 'edit'
            message: 'getting user posts'
            displayTime: 'auto',
        )
        Meteor.call 'get_user_posts', Router.current().params.username, ->
            $('body').toast(
                message: 'posts downloaded'
                showIcon: 'user'
                showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
            )
            Session.set('thinking',false)
      


            
    Template.user_posts.helpers
        user_post_docs: ->
            Docs.find {
                model:'rpost'
                author:Router.current().params.username
            },{
                limit:42
                sort:
                    _timestamp:-1
            }  
    Template.user_comments.helpers
        user_comment_docs: ->
            Docs.find
                model:'rcomment'
                author:Router.current().params.username
            , limit:42
    Template.user.events
        'click .get_user_info': ->
            Meteor.call 'get_user_info', Router.current().params.username, ->
        'click .search_tag': -> 
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            picked_user_tags.clear()
            picked_user_tags.push @valueOf()
            Router.go "/users"

        'click .get_user_posts': ->
            Meteor.call 'get_user_posts', Router.current().params.username, ->
            Meteor.call 'user_omega', Router.current().params.username, ->
            Meteor.call 'rank_user', Router.current().params.username, ->

        'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
        'click .toggle_question_detail': (e,t)-> Session.set('view_question_detail',!Session.get('view_question_detail'))

        'click .search': ->
            # window.speechSynthesis.speak new SpeechSynthesisUtterance "import #{Router.current().params.username}"
            Meteor.call 'search_user', Router.current().params.username, ->
        

    
if Meteor.isServer
    Meteor.publish 'user_posts', (username, limit=42)->
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
    Meteor.publish 'user_comments', (username, limit=42)->
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
                    "User-Agent": "web:com.dao.af:v1.2.3 (by /u/dontlisten65)"
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
    