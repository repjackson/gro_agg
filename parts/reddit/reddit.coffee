if Meteor.isClient
    @picked_rtags = new ReactiveArray []
    @picked_subreddits = new ReactiveArray []
    @picked_subreddit_tags = new ReactiveArray []
    @picked_subreddit_domain = new ReactiveArray []
    @picked_reddit_domain = new ReactiveArray []
    @picked_rtime_tags = new ReactiveArray []
    @picked_rauthors = new ReactiveArray []
    
    
    
    Router.route '/reddit', (->
        @layout 'layout'
        @render 'reddit'
        ), name:'reddit'
    
    Template.reddit.onCreated ->
        Session.setDefault('reddit_skip_value', 0)
        Session.setDefault('reddit_view_layout', 'grid')
        Session.setDefault('sort_key', 'data.created')
        Session.setDefault('sort_direction', -1)
        # Session.setDefault('location_query', null)
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'subrzeddit_user_count', Router.current().params.subreddit
        @autorun => Meteor.subscribe 'rdocs', 
            picked_rtags.array()
            picked_subreddit_domain.array()
            picked_rtime_tags.array()
            picked_subreddits.array()
            picked_rauthors.array()
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('reddit_skip_value')
      
        @autorun => Meteor.subscribe 'reddit_doc_count', 
            Router.current().params.subreddit
            picked_rtags.array()
            picked_reddit_domain.array()
            picked_rtime_tags.array()
            picked_subreddits.array()
    
        @autorun => Meteor.subscribe 'reddit_tags',
            picked_rtags.array()
            picked_reddit_domain.array()
            picked_rtime_tags.array()
            picked_subreddits.array()
            picked_rauthors.array()
            Session.get('toggle')
        Meteor.call 'get_reddit_latest', Router.current().params.subreddit, ->
    
        Meteor.call 'log_reddit_view', Router.current().params.subreddit, ->
        @autorun => Meteor.subscribe 'agg_sentiment_subreddit',
            Router.current().params.subreddit
            picked_rtags.array()
            ()->Session.set('ready',true)
    
    Template.reddit_doc_item.events
        'click .view_post': (e,t)-> 
            Session.set('view_section','main')
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
            # Router.go "/subreddit/#{@subreddit}/post/#{@_id}"
    
    Template.reddit_doc_item.onRendered ->
        # console.log @
        # unless @data.watson
        #     Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
    
    Template.reddit_post_card_small.onRendered ->
        # console.log @
        # unless @data.watson
        #     Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
        unless @time_tags
            Meteor.call 'tagify_time_rpost',@data._id,=>
    
    Template.reddit_page.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)
    Template.reddit_page.onRendered ->
        Meteor.call 'get_post_comments', Router.current().params.subreddit, Router.current().params.doc_id, ->
    
    Template.reddit_page.events
        'click .goto_sub': -> 
            Meteor.call 'get_sub_info', Router.current().params.subreddit, ->
                Meteor.call 'get_sub_latest', Router.current().params.subreddit, ->
                Meteor.call 'log_subreddit_view', Router.current().params.subreddit, ->
        'click .call_visual': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'url', ->
        'click .call_meta': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'meta', ->
        'click .call_thumbnail': -> Meteor.call 'call_visual', Router.current().params.doc_id, 'thumb', ->
        'click .goto_ruser': ->
            doc = Docs.findOne Router.current().params.doc_id
            Meteor.call 'get_user_info', doc.data.author, ->
        'click .get_post': ->
            Session.set('view_section','main')
            Meteor.call 'get_reddit_post', Router.current().params.doc_id, @reddit_id, ->
    
    Template.reddit.events
        'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
        'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
        'click .sort_up': (e,t)-> Session.set('sort_direction',1)
        'click .limit_10': (e,t)-> Session.set('limit',10)
        'click .limit_1': (e,t)-> Session.set('limit',1)
       
        'click .show_newest': (e,t)-> 
            Meteor.call 'reddit_new', ->
            Session.set('reddit_view_mode','newest')
            Session.set('sort_key', 'data.created')
        'click .show_hot': (e,t)-> 
            Meteor.call 'reddit_best', ->
            Session.set('reddit_view_mode','hot')
            Session.set('sort_key', 'data.ups')
        'click .show_best': (e,t)->
            Meteor.call 'reddit_best', ->
            Session.set('sort_key', 'data.ups')
            Session.set('reddit_view_mode','best')
            
        # 'click .sort_created': -> 
        #     Session.set('sort_key', 'data.created')
        # 'click .sort_ups': -> 
        #     Session.set('sort_key', 'data.ups')
    
        'click .download': ->
            Meteor.call 'get_reddit_info', Router.current().params.subreddit, ->
        
        'click .pull_latest': ->
            # console.log 'latest'
            Meteor.call 'get_reddit_latest', Router.current().params.subreddit, ->
        'click .get_info': ->
            # console.log 'dl'
            Meteor.call 'get_reddit_info', Router.current().params.subreddit, ->
        'click .set_grid': (e,t)-> Session.set('reddit_view_layout', 'grid')
        'click .set_list': (e,t)-> Session.set('reddit_view_layout', 'list')
        'click .skip_right': (e,t)-> Session.set('reddit_skip_value', Session.get('reddit_skip_value')+1)
    
        'click .select_reddit_time_tag': ->
            picked_rtime_tags.push @name
    
        'keyup .search_reddit': (e,t)->
            val = $('.search_reddit').val()
            Session.set('reddit_query', val)
            if e.which is 13 
                picked_rtags.push val
                # window.speechSynthesis.speak new SpeechSynthesisUtterance val
    
                $('.search_reddit').val('')
                Session.set('reddit_loading',true)
                Meteor.call 'search_reddit', val, ->
                    Session.set('reddit_loading',false)
                    Session.set('reddit_query', null)
                
    Template.reddit.helpers
        reddit_query: -> Session.get('reddit_query')
    
        domain_selector_class: ->
            if @name in picked_reddit_domain.array() then 'blue' else 'basic'
        sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
        sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
        reddit_result_tags: -> results.find(model:'reddit_tag')
        reddit_domain_tags: -> results.find(model:'reddit_domain_tag')
        reddit_time_tags: -> results.find(model:'reddit_time_tag')
        reddit_subreddits: -> results.find(model:'reddit_subreddit')
    
        skip_value: -> Session.get('reddit_skip_value')
        
        hot_class: ->
            if Session.equals('reddit_view_mode','hot')
                'black'
            else 
                'basic'
        best_class: ->
            if Session.equals('reddit_view_mode','best')
                'black'
            else 
                'basic'
    
        picked_rtags: -> picked_rtags.array()
        
        # reddit_doc: ->
        #     Docs.findOne
        #         model:'subreddit'
        #         "data.display_name":Router.current().params.subreddit
        rdocs: ->
            Docs.find({
                model:'rpost'
                # subreddit:Router.current().params.subreddit
            },
                sort:"#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                limit:20)
        emotion_avg: -> results.findOne(model:'emotion_avg')
    
        sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
        sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
        emotion_avg: -> results.findOne(model:'emotion_avg')
    
        post_count: -> Counts.get('reddit_doc_counter')
    
    
                
    
    
    Template.rtag_picker.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
    Template.rtag_picker.helpers
        selector_class: ()->
            term = 
                Docs.findOne 
                    title:@name.toLowerCase()
            if term
                if term.max_emotion_name
                    switch term.max_emotion_name
                        when 'joy' then " basic green"
                        when "anger" then " basic red"
                        when "sadness" then " basic blue"
                        when "disgust" then " basic orange"
                        when "fear" then " basic grey"
                        else "basic grey"
        term: ->
            Docs.findOne 
                title:@name.toLowerCase()
                
                
    Template.rtag_picker.events
        'click .select_tag': -> 
            # results.update
            # console.log @
            # window.speechSynthesis.cancel()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # if @model is 'reddit_emotion'
            #     picked_emotions.push @name
            # else
            # if @model is 'reddit_tag'
            picked_rtags.push @name
            $('.search_subreddit').val('')
            
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
            Session.set('reddit_loading',true)
            Meteor.call 'search_reddit', @name, ->
                Session.set('reddit_loading',false)
            Meteor.setTimeout( ->
                Session.set('toggle',!Session.get('toggle'))
            , 5000)
            
            
            
    
    Template.unpick_rtag.onCreated ->
        
        @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
        
    Template.unpick_rtag.helpers
        term: ->
            found = 
                Docs.findOne 
                    # model:'wikipedia'
                    title:@valueOf().toLowerCase()
            found
    Template.unpick_rtag.events
        'click .unselect_reddit_tag': -> 
            Session.set('skip',0)
            # console.log @
            picked_rtags.remove @valueOf()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        
    
    Template.flat_pick_rtag.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
    Template.flat_pick_rtag.helpers
        selector_class: ()->
            term = 
                Docs.findOne 
                    title:@valueOf().toLowerCase()
            if term
                if term.max_emotion_name
                    switch term.max_emotion_name
                        when 'joy' then " basic green"
                        when "anger" then " basic red"
                        when "sadness" then " basic blue"
                        when "disgust" then " basic orange"
                        when "fear" then " basic grey"
                        else "basic grey"
        term: ->
            Docs.findOne 
                title:@valueOf().toLowerCase()
    Template.flat_pick_rtag.events
        'click .select_flat_tag': -> 
            # results.update
            # window.speechSynthesis.cancel()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
            picked_rtags.push @valueOf()
            Router.go "/r/#{Router.current().params.subreddit}/"
            $('.search_subreddit').val('')
            Session.set('loading',true)
            Meteor.call 'search_subreddit', Router.current().params.subreddit, @valueOf(), ->
                Session.set('loading',false)
            Meteor.setTimeout( ->
                Session.set('toggle',!Session.get('toggle'))
            , 3000)
            
            
            
if Meteor.isServer
    Meteor.publish 'doc_count', (
        picked_tags
        # picked_authors
        # picked_locations
        # picked_times
        )->
        @unblock()
        match = {
            model:'rpost'
            is_private:$ne:true
        }
        # unless Meteor.userId()
        #     match.privacy='public'
    
            
        if picked_tags.length > 0 then match.tags = $all:picked_tags
        # if picked_authors.length > 0 then match.author = $all:picked_authors
        # if picked_locations.length > 0 then match.location = $all:picked_locations
        # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    
        Counts.publish this, 'doc_count', Docs.find(match)
        return undefined
                
    Meteor.publish 'rposts', (
        picked_tags
        # picked_times
        # picked_locations
        # picked_authors
        # sort_key
        # sort_direction
        # skip=0
        )->
            
        # @unblock()
        self = @
        match = {
            model:'rpost'
            # is_private:$ne:true
            # group:$exists:false
        }
        # unless Meteor.userId()
        #     match.privacy='public'
        
        # if sort_key
        #     sk = sort_key
        # else
        #     sk = '_timestamp'
        # if picked_tags.length > 0 then match.tags = $all:picked_tags
        match.tags = $all:picked_tags
        # if picked_locations.length > 0 then match.location = $all:picked_locations
        # if picked_authors.length > 0 then match.author = $all:picked_authors
        # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    
        # console.log 'match',match
        Docs.find match,
            limit:10
            sort:_timestamp:-1
            # sort: "#{sk}":-1
            # skip:skip*20
            # fields:
            #     title:1
            #     content:1
            #     tags:1
            #     upvoter_ids:1
            #     image_id:1
            #     image_link:1
            #     url:1
            #     youtube_id:1
            #     _timestamp:1
            #     _timestamp_tags:1
            #     views:1
            #     viewer_ids:1
            #     _author_username:1
            #     downvoter_ids:1
            #     _author_id:1
            #     model:1
        
        
    # Meteor.methods    
        # tagify_love: (love)->
        #     doc = Docs.findOne love
        #     # moment(doc.date).fromNow()
        #     # authorstamp = Date.now()
    
        #     doc._authorstamp_long = moment(doc._authorstamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
        #     # doc._app = 'love'
        
        #     date = moment(doc.date).format('Do')
        #     weekdaynum = moment(doc.date).isoWeekday()
        #     weekday = moment().isoWeekday(weekdaynum).format('dddd')
        
        #     hour = moment(doc.date).format('h')
        #     minute = moment(doc.date).format('m')
        #     ap = moment(doc.date).format('a')
        #     month = moment(doc.date).format('MMMM')
        #     year = moment(doc.date).format('YYYY')
        
        #     # doc.points = 0
        #     # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
        #     date_array = [ap, weekday, month, date, year]
        #     if _
        #         date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        #         doc._authorstamp_tags = date_array
        #         # console.log 'love', date_array
        #         Docs.update love, 
        #             $set:addedauthors:date_array
        
               
    Meteor.publish 'rtags', (
        picked_tags
        # picked_times
        # picked_locations
        # picked_authors
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            model:'rpost'
            # model:'post'
            # is_private:$ne:true
            # sublove:sublove
        }
    
    
        # unless Meteor.userId()
        #     match.privacy='public'
    
        # if picked_tags.length > 0 then match.tags = $all:picked_tags
        match.tags = $all:picked_tags
        # if picked_authors.length > 0 then match.author = $all:picked_authors
        # if picked_locations.length > 0 then match.location = $all:picked_locations
        # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
        doc_count = Docs.find(match).count()
        console.log 'doc_count', doc_count
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        tag_cloud.forEach (tag, i) ->
            console.log tag
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tag'
        
        # location_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "location_tags": 1 }
        #     { $unwind: "$location_tags" }
        #     { $group: _id: "$location_tags", count: $sum: 1 }
        #     # { $match: _id: $nin: picked_location }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:10 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ]
        # location_cloud.forEach (location, i) ->
        #     self.added 'results', Random.id(),
        #         name: location.name
        #         count: location.count
        #         model:'location_tag'
        
        
        # timestamp_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "timestamp_tags": 1 }
        #     { $unwind: "$timestamp_tags" }
        #     { $group: _id: "$timestamp_tags", count: $sum: 1 }
        #     # { $match: _id: $nin: picked_time }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:10 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ]
        # # console.log match
        # timestamp_cloud.forEach (time, i) ->
        #     # console.log 'time', time
        #     self.added 'results', Random.id(),
        #         name: time.name
        #         count: time.count
        #         model:'timestamp_tag'
        
        
        # time_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "time_tags": 1 }
        #     { $unwind: "$time_tags" }
        #     { $group: _id: "$time_tags", count: $sum: 1 }
        #     # { $match: _id: $nin: picked_time }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:10 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ]
        # # console.log match
        # timestamp_cloud.forEach (time, i) ->
        #     # console.log 'time', time
        #     self.added 'results', Random.id(),
        #         name: time.name
        #         count: time.count
        #         model:'time_tag'
        
        
        
        # author_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "author": 1 }
        #     # { $unwind: "$author" }
        #     { $group: _id: "$author", count: $sum: 1 }
        #     { $match: _id: $nin: picked_authors }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:10 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ]
        # author_cloud.forEach (author, i) ->
        #     self.added 'results', Random.id(),
        #         name: author.name
        #         count: author.count
        #         model:'author'
        
        
        self.ready()
# @picked_tags = new ReactiveArray []
# @picked_times = new ReactiveArray []
# @picked_locations = new ReactiveArray []
# @picked_authors = new ReactiveArray []

# Router.route '/p/:doc_id/edit', (->
#     @layout 'layout'
#     @render 'post_edit'
#     ), name:'post_edit'


# Template.nav.onCreated ->
#     # Session.setDefault('session_clicks', 0)
# Template.home.onCreated ->
#     Session.setDefault('sort_key', '_timestamp')
#     Session.setDefault('sort_direction', -1)
#     # Session.setDefault('location_query', null)
#     @autorun => Meteor.subscribe 'rtags',
#         picked_tags.array()
#         # picked_times.array()
#         # picked_locations.array()
#         # picked_authors.array()
#     @autorun => Meteor.subscribe 'post_count', 
#         picked_tags.array()
#         # picked_times.array()
#         # picked_locations.array()
#         # picked_authors.array()
#     @autorun => Meteor.subscribe 'posts', 
#         picked_tags.array()
#         # picked_times.array()
#         # picked_locations.array()
#         # picked_authors.array()
#         # Session.get('sort_key')
#         # Session.get('sort_direction')
#         # Session.get('skip_value')



# Template.post_card.onRendered ->
#     # console.log @
#     Meteor.call 'log_view', @data._id, ->
#     # Session.set('session_clicks', Session.get('session_clicks')+2)



# Template.post_card.helpers
#     card_class: ->
#         if Meteor.userId()
#             if @viewer_ids 
#                 if Meteor.userId() in @viewer_ids
#                     'link'
#                 else
#                     'raised link'
#             else
#                 'raised link'
#         else
#             'raised link'
# Template.home.helpers
#     posts: ->
#         Docs.find {
#             model:$in:['post','rpost']
#         }, sort: _timestamp:-1
       
#     picked_tags: -> picked_tags.array()
#     picked_locations: -> picked_locations.array()
#     picked_authors: -> picked_authors.array()
#     picked_times: -> picked_times.array()
#     post_counter: -> Counts.get 'post_counter'
    
#     result_tags: -> results.find(model:'tag')
#     author_results: -> results.find(model:'author')
#     location_results: -> results.find(model:'location_tag')
#     time_results: -> results.find(model:'time_tag')
        
#     sidebar_class: -> if Session.get('view_sidebar') then 'ui four wide column' else 'hidden'
#     main_column_class: -> if Session.get('view_sidebar') then 'ui twelve wide column' else 'ui sixteen wide column' 
        
# Template.rpost_card.events
#     'click .get_post': ->
#         Meteor.call 'get_reddit_post', @_id, ->
# Template.user_post_small.events
#     'click .mark_viewed': (e,t)->
#         Meteor.call 'log_view', @_id, ->
#         if Meteor.userId()
#             Docs.update @_id,
#                 $addToSet:viewer_ids:Meteor.userId()
#         Meteor.users.update @_author_id,
#             $inc:points:1
# Template.home.events
#     'click .enable_sidebar': (e,t)-> Session.set('view_sidebar',true)
#     'click .disable_sidebar': (e,t)-> Session.set('view_sidebar',false)
#     'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
#     'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
#     'click .sort_up': (e,t)-> Session.set('sort_direction',1)

#     'click .set_grid': (e,t)-> Session.set('view_layout', 'grid')
#     'click .set_list': (e,t)-> Session.set('view_layout', 'list')


#     'click .mark_viewed': (e,t)->
#         if Meteor.userId()
#             Docs.update @_id,
#                 $addToSet:viewer_ids:Meteor.userId()
#             Meteor.users.update @_author_id,
#                 $inc:points:1
#     'keyup .search_tag': (e,t)->
#          if e.which is 13
#             val = t.$('.search_tag').val().trim().toLowerCase()
#             # window.speechSynthesis.speak new SpeechSynthesisUtterance val
#             $('.search_tag').transition('pulse')
#             $('.black').transition('pulse')
#             $('.seg .pick_tag').transition({
#                 animation : 'pulse',
#                 duration  : 500,
#                 interval  : 300
#             })
#             $('.seg .black').transition({
#                 animation : 'pulse',
#                 duration  : 500,
#                 interval  : 300
#             })
#             # $('.pick_tag').transition('pulse')
#             # $('.card_small').transition('shake')
#             $('.pushed .card_small').transition({
#                 animation : 'pulse',
#                 duration  : 500,
#                 interval  : 300
#             })
#             picked_tags.push val   
#             t.$('.search_tag').val('')
#             # Session.set('sub_doc_query', val)
#             Meteor.call 'search_reddit', picked_tags.array(), ->
#                 Session.set('loading',false)
#             Meteor.setTimeout ->
#                 Session.set('toggle',!Session.get('toggle'))
#             , 5000



#     'click .make_private': ->
#         # if confirm 'make private?'
#         Docs.update @_id,
#             $set:is_private:true

#     'click .upvote': ->
#         Docs.update @_id,
#             $inc:points:1
#     'click .downvote': ->
#         Docs.update @_id,
#             $inc:points:-1
#     'keyup .add_tag': (e,t)->
#         if e.which is 13
#             new_tag = $(e.currentTarget).closest('.add_tag').val().toLowerCase().trim()
#             Docs.update @_id,
#                 $addToSet: tags:new_tag
#             $(e.currentTarget).closest('.add_tag').val('')
            
            
#     'click .unpick_time': ->
#         picked_times.remove @valueOf()
#     'click .pick_time': ->
#         picked_times.push @name
#         window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
#     'click .pick_flat_time': ->
#         picked_times.push @valueOf()
#         window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
#     'click .unpick_location': ->
#         picked_locations.remove @valueOf()
#     'click .pick_location': ->
#         picked_locations.push @name
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
#     'click .unpick_author': ->
#         picked_authors.remove @valueOf()
#     'click .pick_author': ->
#         picked_authors.push @name
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name

#     'click .unpick_Location': ->
#         picked_Locations.remove @valueOf()
#     'click .pick_Location': ->
#         picked_Locations.push @name
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
#     'click .unpick_time_tag': ->
#         group_picked_time_tags.remove @valueOf()
#     'click .pick_time_tag': ->
#         group_picked_time_tags.push @name
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
        
#     'click .unpick_timestamp_tag': ->
#         group_picked_timestamp_tags.remove @valueOf()
#     'click .pick_timestamp_tag': ->
#         group_picked_timestamp_tags.push @name
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        
#     'click .unpick_location_tag': ->
#         group_picked_location_tags.remove @valueOf()
#     'click .pick_location_tag': ->
#         group_picked_location_tags.push @name
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
  
#     'click .unpick_author': ->
#         group_picked_author_tags.remove @valueOf()
#     'click .pick_author': ->
#         group_picked_author_tags.push @name
#         # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
    
     
#     'keyup .search_love_tag': (e,t)->
#          if e.which is 13
#             val = t.$('.search_love_tag').val().trim().toLowerCase()
#             # window.speechSynthesis.speak new SpeechSynthesisUtterance val
#             picked_tags.push val   
#             t.$('.search_love_tag').val('')
            
            
#     Template.tag_picker.onCreated ->
#         # @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
#     Template.tag_picker.helpers
#         picker_class: ()->
#             term = 
#                 Docs.findOne 
#                     title:@name.toLowerCase()
#             if term
#                 if term.max_emotion_name
#                     switch term.max_emotion_name
#                         when 'joy' then " basic green"
#                         when "anger" then " basic red"
#                         when "sadness" then " basic blue"
#                         when "disgust" then " basic orange"
#                         when "fear" then " basic grey"
#                         else "basic grey"
#         term: ->
#             res = 
#                 Docs.findOne 
#                     title:@name.toLowerCase()
#             # console.log res
#             res
                
#     Template.tag_picker.events
#         'click .pick_tag': -> 
#             # results.update
#             # console.log @
#             # window.speechSynthesis.cancel()
#             window.speechSynthesis.speak new SpeechSynthesisUtterance @name
#             # if @model is 'love_emotion'
#             #     picked_emotions.push @name
#             # else
#             # if @model is 'love_tag'
#             picked_tags.push @name
#             # $('.search_sublove').val('')
#             # Session.set('skip_value',0)
    
#             # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
#             # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
#             # Session.set('love_loading',true)
#             Meteor.call 'search_reddit', picked_tags.array(), ->
#                 Session.set('loading',false)
#                 # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array()
#             Meteor.setTimeout ->
#                 Session.set('toggle',!Session.get('toggle'))
#             , 5000

            
            
    
#     Template.unpick_tag.onCreated ->
#         # @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
        
#     Template.unpick_tag.helpers
#         term: ->
#             found = 
#                 Docs.findOne 
#                     # model:'wikipedia'
#                     title:@valueOf().toLowerCase()
#             found
#     Template.unpick_tag.events
#         'click .unpick_tag': -> 
#             Session.set('skip',0)
#             # console.log @
#             picked_tags.remove @valueOf()
#             # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        
    
#     Template.flat_tag_picker.onCreated ->
#         # @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
#     Template.flat_tag_picker.helpers
#         picker_class: ()->
#             term = 
#                 Docs.findOne 
#                     title:@valueOf().toLowerCase()
#             if term
#                 if term.max_emotion_name
#                     switch term.max_emotion_name
#                         when 'joy' then " basic green"
#                         when "anger" then " basic red"
#                         when "sadness" then " basic blue"
#                         when "disgust" then " basic orange"
#                         when "fear" then " basic grey"
#                         else "basic grey"
#         term: ->
#             Docs.findOne 
#                 title:@valueOf().toLowerCase()
#     Template.flat_tag_picker.events
#         'click .pick_flat_tag': -> 
#             # results.update
#             # window.speechSynthesis.cancel()
#             # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
#             picked_tags.push @valueOf()
#             $('.search_tags').val('')

if Meteor.isClient
    @picked_locations = new ReactiveArray []
    @picked_authors = new ReactiveArray []
    @picked_times = new ReactiveArray []
    
    Template.home.onCreated ->
        params = new URLSearchParams(window.location.search);
        
        tags = params.get("tags");
        if tags
            split = tags.split(',')
            if tags.length > 0
                for tag in split 
                    unless tag in picked_tags.array()
                        picked_tags.push tag
                Session.set('loading',true)
                Meteor.call 'search_reddit', picked_tags.array(), ->
                    Session.set('loading',false)
                Meteor.setTimeout ->
                    Session.set('toggle', !Session.get('toggle'))
                , 5000    
                Meteor.setTimeout ->
                    Session.set('toggle', !Session.get('toggle'))
                , 10000    
                
        # console.log(name)
        
        Session.setDefault('sort_key', 'points')
        Session.setDefault('sort_direction', -1)
        Session.setDefault('view_layout', 'grid')
        # Session.setDefault('view_sidebar', -false)
        Session.setDefault('view_videos', -false)
        Session.setDefault('view_images', -false)
        Session.setDefault('view_adult', -false)
        # Session.setDefault('location_query', null)
        @autorun => Meteor.subscribe 'rtags',
            picked_tags.array()
            Session.get('toggle')
            picked_times.array()
            picked_locations.array()
            picked_authors.array()
            Session.get('view_videos')
            Session.get('view_images')
            Session.get('view_adult')
        @autorun => Meteor.subscribe 'post_count', 
            picked_tags.array()
            picked_times.array()
            picked_locations.array()
            picked_authors.array()
            Session.get('view_videos')
            Session.get('view_images')
            Session.get('view_adult')
        @autorun => Meteor.subscribe 'posts', 
            picked_tags.array()
            Session.get('toggle')
            picked_times.array()
            picked_locations.array()
            picked_authors.array()
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('skip_value')
            Session.get('view_videos')
            Session.get('view_images')
            Session.get('view_adult')
    
    
    
    Template.home.helpers
        posts: ->
            Docs.find {
                model:'rpost'
            }, sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
           
        picked_tags: -> picked_tags.array()
        # picked_locations: -> picked_locations.array()
        # picked_authors: -> picked_authors.array()
        # picked_times: -> picked_times.array()
        post_counter: -> Counts.get 'post_counter'
        
        nightmode_class: -> if Session.get('nightmode') then 'invert'
        
        
        result_tags: -> results.find(model:'tag')
        # author_results: -> results.find(model:'author')
        # location_results: -> results.find(model:'location_tag')
        # time_results: -> results.find(model:'time_tag')
        
        sort_points_class: -> if Session.equals('sort_key','points') then 'black' else ''
        sort_created_class: -> if Session.equals('sort_key','data.created') then 'black' else ''
        video_class: -> if Session.get('view_videos') then 'black' else ''
        image_class: -> if Session.get('view_images') then 'black' else ''
        adult_class: -> if Session.get('view_adult') then 'black' else ''
        
        # sidebar_class: -> if Session.get('view_sidebar') then 'ui four wide column' else 'hidden'
        # main_column_class: -> if Session.get('view_sidebar') then 'ui twelve wide column' else 'ui sixteen wide column' 
            
    Template.home.events
        # 'click .enable_sidebar': (e,t)-> Session.set('view_sidebar',true)
        # 'click .disable_sidebar': (e,t)-> Session.set('view_sidebar',false)
        # 'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
        'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
        'click .sort_up': (e,t)-> Session.set('sort_direction',1)
        'click .toggle_nightmode': -> Session.set('nightmode',!Session.get('nightmode'))
      
        'click .view_videos': (e,t)-> Session.set('view_videos',!Session.get('view_videos'))
        'click .view_images': (e,t)-> Session.set('view_images',!Session.get('view_images'))
        'click .view_adult': (e,t)-> 
            unless Session.get('view_adult')
                if confirm 'view adult?'
                    Session.set('view_adult',true)
            else
                Session.set('view_adult',false)
                # Session.set('view_adult',!Session.get('view_adult'))
    
        'click .set_grid': (e,t)-> Session.set('view_layout', 'grid')
        'click .set_list': (e,t)-> Session.set('view_layout', 'list')
    
        'click .sort_points': (e,t)-> Session.set('sort_key', 'points')
        'click .sort_created': (e,t)-> Session.set('sort_key', 'data.created')
    
        # 'click .mark_viewed': (e,t)->
        #     Docs.update @_id,
        #         $inc:views:1
        'click .search_tag': (e,t)->
            Session.set('toggle', !Session.get('toggle'))
    
        'keyup .search_tag': (e,t)->
             if e.which is 13
                val = t.$('.search_tag').val().trim().toLowerCase()
                Session.set('loading',true)
                picked_tags.push val   
                Meteor.call 'search_reddit', picked_tags.array(), ->
                    Session.set('loading',false)
                # window.speechSynthesis.speak new SpeechSynthesisUtterance val
                # $('.search_tag').transition('pulse')
                # $('.black').transition('pulse')
                # $('.seg .pick_tag').transition({
                #     animation : 'pulse',
                #     duration  : 500,
                #     interval  : 300
                # })
                # $('.seg .black').transition({
                #     animation : 'pulse',
                #     duration  : 500,
                #     interval  : 300
                # })
                # $('.pick_tag').transition('pulse')
                # $('.card_small').transition('shake')
                # $('.pushed .card').transition({
                #     animation : 'pulse',
                #     duration  : 500,
                #     interval  : 300
                # })
                Meteor.setTimeout ->
                    Session.set('toggle', !Session.get('toggle'))
                , 5000    
                Meteor.setTimeout ->
                    Session.set('toggle', !Session.get('toggle'))
                , 10000    
                url = new URL(window.location);
                url.searchParams.set('tags', picked_tags.array());
                window.history.pushState({}, '', url);
                document.title = picked_tags.array()
                
                t.$('.search_tag').val('')
                t.$('.search_tag').focus()
                # Session.set('sub_doc_query', val)
    
    
    
        'click .make_private': ->
            # if confirm 'make private?'
            Docs.update @_id,
                $set:is_private:true
    
        # 'keyup .add_tag': (e,t)->
        #     if e.which is 13
        #         new_tag = $(e.currentTarget).closest('.add_tag').val().toLowerCase().trim()
        #         Docs.update @_id,
        #             $addToSet: tags:new_tag
        #         $(e.currentTarget).closest('.add_tag').val('')
                

if Meteor.isServer
    request = require('request')
    rp = require('request-promise');
    Meteor.methods
        search_reddit: (query)->
            @unblock()
            # res = HTTP.get("http://reddit.com/search.json?q=#{query}")
            # if subreddit 
            #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
            # else
            url = "http://reddit.com/search.json?q=#{query}&over_18=1&limit=100&include_facets=false&raw_json=1"
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
                                if Meteor.isDevelopment
                                    console.log 'existing', existing
                                # if typeof(existing.tags) is 'string'
                                #     Doc.update
                                #         $unset: tags: 1
                                Docs.update existing._id,
                                    $addToSet: tags: $each: added_tags
                                    $set:data:data
    
                                # Meteor.call 'get_reddit_post', existing._id, data.id, (err,res)->
                            unless existing
                                new_reddit_post_id = Docs.insert reddit_post
                                if Meteor.isDevelopment
                                    console.log 'new', new_reddit_post_id
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
        
        calc_sub_tags: (subreddit)->
            found = 
                Docs.findOne(
                    model:'subreddit'
                    "data.display_name": subreddit
                )
            sub_tags = Meteor.call 'agg_sub_tags', subreddit
            titles = _.pluck(sub_tags, 'title')
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
    
            
            
            
        get_sub_info: (subreddit)->
            @unblock()
            console.log 'getting', subreddit
            # if subreddit 
            #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
            # else
            # url = "https://www.reddit.com/r/#{subreddit}/about.json?&raw_json=1&include_over_18=on"
            url = "https://www.reddit.com/r/#{subreddit}/about.json?&raw_json=1"
            HTTP.get url,(err,res)=>
                if res.data.data
                    console.log res.data.data
                    existing = Docs.findOne 
                        model:'subreddit'
                        name:subreddit
                        # "data.display_name":subreddit
                    if existing
                        console.log existing
                        # if Meteor.isDevelopment
                        # if typeof(existing.tags) is 'string'
                        #     Doc.update
                        #         $unset: tags: 1
                        Docs.update existing._id,
                            $set: data:res.data.data
                    unless existing
                        console.log 'not existing'
                        sub = {}
                        sub.model = 'subreddit'
                        sub.name = subreddit
                        sub.data = res.data.data
                        new_reddit_post_id = Docs.insert sub
                        # console.log existing
        
        get_sub_latest: (subreddit)->
            @unblock()
            # if subreddit 
            #     url = "http://reddit.com/r/#{subreddit}/search.json?q=#{query}&nsfw=1&limit=25&include_facets=false"
            # else
            url = "https://www.reddit.com/r/#{subreddit}.json?&raw_json=1&include_over_18=on&search_include_over_18=on&limit=100"
            HTTP.get url,(err,res)=>
                # if err
                # if res 
                # if res.data.data.dist > 1
                _.each(res.data.data.children[0..100], (item)=>
                    found = 
                        Docs.findOne    
                            model:'rpost'
                            reddit_id:item.data.id
                            # subreddit:item.data.id
                    if found
                        Docs.update found._id,
                            $set:subreddit:item.data.subreddit
                    unless found
                        item.model = 'rpost'
                        item.reddit_id = item.data.id
                        item.author = item.data.author
                        item.subreddit = item.data.subreddit
                        # item.rdata = item.data
                        Docs.insert item
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
                        unless found
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
    
        # search_subreddits: (search)->
        #     @unblock()
        #     HTTP.get "http://reddit.com/subreddits/search.json?q=#{search}&raw_json=1&nsfw=1", (err,res)->
        #         if res.data.data.dist > 1
        #             _.each(res.data.data.children[0..200], (item)=>
        #                 found = 
        #                     Docs.findOne    
        #                         model:'subreddit'
        #                         "data.display_name":item.data.display_name
        #                 # if found
        #                 unless found
        #                     item.model = 'subreddit'
        #                     Docs.insert item
        #             )
        search_subreddits: (search)->
            # console.log 'searching subs', search
            @unblock()
            HTTP.get "http://reddit.com/subreddits/search.json?q=#{search}&raw_json=1&nsfw=1&include_over_18=on&limit=100", (err,res)->
                if res.data.data.dist > 1
                    _.each(res.data.data.children[0..100], (item)=>
                        # console.log item.data.display_name
                        added_tags = [search]
                        added_tags = _.flatten(added_tags)
                        # console.log 'added tags', added_tags
                        found = 
                            Docs.findOne    
                                model:'subreddit'
                                "data.display_name":item.data.display_name
                        if found
                            # console.log 'found', search, item.data.display_name
                            Docs.update found._id, 
                                $addToSet: tags: $each: added_tags
                        unless found
                            # console.log 'not found', item.data.display_name
                            item.model = 'subreddit'
                            item.tags = added_tags
                            Docs.insert item
                            
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
                        "data.display_name":subreddit
                    if existing
                        # console.log 'existing', existing
                        # if Meteor.isDevelopment
                        # if typeof(existing.tags) is 'string'
                        #     Doc.update
                        #         $unset: tags: 1
                        Docs.update existing._id,
                            $set: data:res.data.data
                    unless existing
                        # console.log 'new sub', subreddit
                        sub = {}
                        sub.model = 'subreddit'
                        sub.name = subreddit
                        sub.data = res.data.data
                        new_reddit_post_id = Docs.insert sub
                  
        search_subreddit: (subreddit,search)->
            @unblock()
            HTTP.get "http://reddit.com/r/#{subreddit}/search.json?q=#{search}&restrict_sr=1&raw_json=1&include_over_18=on&nsfw=1", (err,res)->
                if res.data.data.dist > 1
                    for item in res.data.data.children[0..3]
                        id = item.data.id
                        # Docs.insert d
                        # found = 
                        found = Docs.findOne({
                            model:'rpost',
                            "data.subreddit":item.data.subreddit
                            # reddit_id:id
                        })
                        # continue
                    # _.each(res.data.data.children[0..100], (item)=>
                    #     id = item.data.id
                    #     # if found
                    #     #     Docs.update found._id, 
                    #     #         $addToSet: tags: search
                    #     #         $set:
                    #     #             subreddit:item.data.subreddit
                    #     # unless found
                    #     #     item.model = 'rpost'
                    #     #     item.reddit_id = item.data.id
                    #     #     item.author = item.data.author
                    #     #     item.subreddit = item.data.subreddit
                    #     #     item.tags = [search]
                    #     #     # item.rdata = item.data
                    #     #     Docs.insert item
                    # )
                    
            
        tagify_time_rpost: (doc_id)->
            doc = Docs.findOne doc_id
            # moment.unix(doc.data.created).fromNow()
            # timestamp = Date.now()
    
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
                doc._timestamp_tags = date_array
                Docs.update doc_id, 
                    $set:time_tags:date_array
                            
    
    Meteor.publish 'subreddit_by_param', (subreddit)->
        Docs.find
            model:'subreddit'
            name:subreddit
            # "data.display_name":subreddit
            
    Meteor.publish 'related_posts', (post_id)->
        post = Docs.findOne post_id
            
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
        related_cur
        
                
    Meteor.publish 'rpost_comments', (subreddit, doc_id)->
        post = Docs.findOne doc_id
        Docs.find
            model:'rcomment'
            parent_id:"t3_#{post.reddit_id}"
            
    Meteor.publish 'subreddits', (
        query=''
        picked_tags
        sort_key='data.subscribers'
        skip=0
        sort_direction=-1
        )->
        match = {model:'subreddit'}
        if picked_tags.length > 0 then match.tags = $all:picked_tags
        if query.length > 0
            match["data.display_name"] = {$regex:"#{query}", $options:'i'}
        Docs.find match,
            limit:20
            sort: "#{sort_key}":sort_direction
            skip:skip*20
            
    
    Meteor.publish 'sub_count', (
        query=''
        picked_tags
        )->
            
        match = {model:'subreddit'}
        if picked_tags.length > 0 then match.tags = $all:picked_tags
        if query.length > 0
            match["data.display_name"] = {$regex:"#{query}", $options:'i'}
        Counts.publish this, 'sub_counter', Docs.find(match)
        return undefined
    
    
            
            
    Meteor.publish 'sub_docs_by_name', (
        subreddit
        selected_subreddit_tags
        selected_subreddit_domains
        selected_subreddit_time_tags
        selected_subreddit_authors
        sort_key
        )->
        self = @
        match = {
            model:'rpost'
            subreddit:subreddit
        }
        if sort_key
            sk = sort_key
        else
            sk = 'data.created'
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if selected_subreddit_tags.length > 0 then match.tags = $all:selected_subreddit_tags
        if selected_subreddit_domains.length > 0 then match.domain = $all:selected_subreddit_domains
        if selected_subreddit_time_tags.length > 0 then match.time_tags = $all:selected_subreddit_time_tags
        if selected_subreddit_authors.length > 0 then match.authors = $all:selected_subreddit_authors
        Docs.find match,
            limit:20
            sort: "#{sk}":-1
        
        
    Meteor.publish 'agg_sentiment_subreddit', (
        subreddit
        picked_tags
        )->
        # @unblock()
        self = @
        match = {
            model:'rpost'
            subreddit:subreddit
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
        
    
    Meteor.publish 'sub_doc_count', (
        subreddit
        picked_tags
        selected_subreddit_domains
        selected_subreddit_time_tags
        )->
            
        match = {model:'rpost'}
        match.subreddit = subreddit
        if picked_tags.length > 0 then match.tags = $all:picked_tags
        if selected_subreddit_domains.length > 0 then match.domain = $all:selected_subreddit_domains
        if selected_subreddit_time_tags.length > 0 then match.time_tags = $all:selected_subreddit_time_tags
        Counts.publish this, 'sub_doc_counter', Docs.find(match)
        return undefined
    
    
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
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'rpost_comment_tag'
                
        self.ready()
                
        
    Meteor.publish 'subreddit_result_tags', (
        subreddit
        selected_subreddit_tags
        selected_subreddit_domain
        selected_subreddit_time_tags
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
        if selected_subreddit_tags.length > 0 then match.tags = $all:selected_subreddit_tags
        if selected_subreddit_domain.length > 0 then match.domain = $all:selected_subreddit_domain
        if selected_subreddit_time_tags.length > 0 then match.time_tags = $all:selected_subreddit_time_tags
        # if selected_emotion.length > 0 then match.max_emotion_name = selected_emotion
        doc_count = Docs.find(match).count()
        subreddit_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_subreddit_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:11 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        subreddit_tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'subreddit_result_tag'
        
        
        subreddit_domain_cloud = Docs.aggregate [
            { $match: match }
            { $project: "data.domain": 1 }
            # { $unwind: "$domain" }
            { $group: _id: "$data.domain", count: $sum: 1 }
            # { $match: _id: $nin: selected_domains }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        subreddit_domain_cloud.forEach (domain, i) ->
            self.added 'results', Random.id(),
                name: domain.name
                count: domain.count
                model:'subreddit_domain_tag'
      
      
        
        subreddit_time_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "time_tags": 1 }
            { $unwind: "$time_tags" }
            { $group: _id: "$time_tags", count: $sum: 1 }
            # { $match: _id: $nin: selected_subreddit_time_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        subreddit_time_tag_cloud.forEach (time_tag, i) ->
            self.added 'results', Random.id(),
                name: time_tag.name
                count: time_tag.count
                model:'subreddit_time_tag'
      
      
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
    
        
    Meteor.publish 'subs_tags', (
        selected_subreddit_tags
        selected_subreddit_domain
        selected_subreddit_authors
        # view_bounties
        # view_unanswered
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            model:'subreddit'
            # subreddit:subreddit
        }
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if selected_subreddit_tags.length > 0 then match.tags = $all:selected_subreddit_tags
        if selected_subreddit_authors.length > 0 then match.author = $all:selected_subreddit_authors
        # if selected_emotion.length > 0 then match.max_emotion_name = selected_emotion
        doc_count = Docs.find(match).count()
        sus_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_subreddit_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:42 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        sus_tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'subs_tag'
        
        
        subreddit_author_cloud = Docs.aggregate [
            { $match: match }
            { $project: "author": 1 }
            # { $unwind: "$author" }
            { $group: _id: "$author", count: $sum: 1 }
            # { $match: _id: $nin: selected_authors }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        subreddit_author_cloud.forEach (author, i) ->
            self.added 'results', Random.id(),
                name: author.name
                count: author.count
                model:'subreddit_author_tag'
      
        self.ready()
    
        
    Meteor.methods 
        log_subreddit_view: (name)->
            sub = Docs.findOne
                model:'subreddit'
                "rdata.display_name":name
            if sub
                Docs.update sub._id,
                    $inc:dao_views:1
                    
                    
                    
    Meteor.publish 'rdocs', (
        selected_reddit_tags
        selected_subreddit_tags
        selected_subreddit_domains
        selected_reddit_subreddits
        selected_reddit_authors
        sort_key
        sort_direction
        skip=0
        )->
        self = @
        match = {
            model:'rpost'
        }
        if sort_key
            sk = sort_key
        else
            sk = 'data.created'
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if selected_reddit_tags.length > 0 then match.tags = $all:selected_reddit_tags
        if selected_subreddit_tags.length > 0 then match.subreddit = $all:selected_subreddit_tags
        if selected_subreddit_domains.length > 0 then match.domain = $all:selected_subreddit_domains
        if selected_reddit_subreddits.length > 0 then match.subreddit = $all:selected_reddit_subreddits
        if selected_reddit_authors.length > 0 then match.author = $all:selected_reddit_authors
        Docs.find match,
            limit:20
            sort: "#{sk}":-1
            skip:skip*20
        
               
    Meteor.publish 'reddit_tags', (
        selected_reddit_tags
        selected_subreddit_domain
        selected_reddit_time_tags
        selected_reddit_subreddits
        selected_reddit_authors
        # view_bounties
        # view_unanswered
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            model:'rpost'
            # subreddit:subreddit
        }
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if selected_reddit_tags.length > 0 then match.tags = $all:selected_reddit_tags
        if selected_subreddit_domain.length > 0 then match.domain = $all:selected_subreddit_domain
        if selected_reddit_time_tags.length > 0 then match.domain = $all:selected_reddit_time_tags
        if selected_reddit_subreddits.length > 0 then match.subreddit = $all:selected_reddit_subreddits
        if selected_reddit_authors.length > 0 then match.author = $all:selected_reddit_authors
        # if selected_emotion.length > 0 then match.max_emotion_name = selected_emotion
        doc_count = Docs.find(match).count()
        reddit_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_reddit_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        reddit_tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'reddit_tag'
        
        
        reddit_domain_cloud = Docs.aggregate [
            { $match: match }
            { $project: "data.domain": 1 }
            # { $unwind: "$domain" }
            { $group: _id: "$data.domain", count: $sum: 1 }
            # { $match: _id: $nin: selected_domains }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        reddit_domain_cloud.forEach (domain, i) ->
            self.added 'results', Random.id(),
                name: domain.name
                count: domain.count
                model:'reddit_domain_tag'
        
        
        reddit_subreddits_cloud = Docs.aggregate [
            { $match: match }
            { $project: "data.subreddit": 1 }
            # { $unwind: "$subreddit" }
            { $group: _id: "$data.subreddit", count: $sum: 1 }
            # { $match: _id: $nin: selected_subreddits }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        reddit_subreddits_cloud.forEach (subreddit, i) ->
            self.added 'results', Random.id(),
                name: subreddit.name
                count: subreddit.count
                model:'reddit_subreddit'
        
        
        
        reddit_time_cloud = Docs.aggregate [
            { $match: match }
            { $project: "time_tags": 1 }
            { $unwind: "$time_tags" }
            { $group: _id: "$time_tags", count: $sum: 1 }
            { $match: _id: $nin: selected_reddit_time_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        reddit_time_cloud.forEach (time_tag, i) ->
            self.added 'results', Random.id(),
                name: time_tag.name
                count: time_tag.count
                model:'reddit_time_tag'
      
        self.ready()
