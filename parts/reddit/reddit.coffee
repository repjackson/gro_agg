if Meteor.isClient
    @picked_tags = new ReactiveArray []
    @picked_subreddits = new ReactiveArray []
    @picked_subreddit_domain = new ReactiveArray []
    @picked_reddit_domain = new ReactiveArray []
    @picked_rtime_tags = new ReactiveArray []
    @picked_rauthors = new ReactiveArray []
    
    @picked_locations = new ReactiveArray []
    @picked_authors = new ReactiveArray []
    @picked_times = new ReactiveArray []
    
    
    
    Router.route '/reddit', (->
        @layout 'layout'
        @render 'reddit'
        ), name:'reddit'
    
    Template.reddit.onCreated ->
        Session.setDefault('reddit_skip_value', 0)
        Session.setDefault('reddit_view_layout', 'grid')
        Session.setDefault('sort_key', 'data.created')
        Session.setDefault('sort_direction', -1)
        Session.setDefault('nsfw', false)
        # Session.setDefault('location_query', null)
        @autorun => Meteor.subscribe 'rposts', 
            picked_tags.array()
            Session.get('nsfw')
            # picked_subreddit_domain.array()
            # picked_rtime_tags.array()
            # picked_subreddits.array()
            # picked_rauthors.array()
            # Session.get('sort_key')
            # Session.get('sort_direction')
            # Session.get('reddit_skip_value')
      
        # @autorun => Meteor.subscribe 'reddit_post_count', 
        #     picked_tags.array()
        #     picked_reddit_domain.array()
        #     picked_rtime_tags.array()
        #     picked_subreddits.array()
        params = new URLSearchParams(window.location.search);
        
        tags = params.get("tags");
        # if tags
        #     split = tags.split(',')
        #     if tags.length > 0
        #         for tag in split 
        #             unless tag in picked_tags.array()
        #                 picked_tags.push tag
        #         Session.set('loading',true)
        #         Meteor.call 'search_reddit', picked_tags.array(), ->
        #             Session.set('loading',false)
        #         Meteor.setTimeout ->
        #             Session.set('toggle', !Session.get('toggle'))
        #         , 5000    
        #         Meteor.setTimeout ->
        #             Session.set('toggle', !Session.get('toggle'))
        #         , 10000    
                
        # console.log(name)
        
        Session.setDefault('sort_key', 'points')
        Session.setDefault('sort_direction', -1)
        Session.setDefault('view_layout', 'grid')
        # Session.setDefault('view_sidebar', false)
        Session.setDefault('view_videos', false)
        Session.setDefault('view_images', false)
        Session.setDefault('view_adult', false)
        # Session.setDefault('location_query', null)
        # @autorun => Meteor.subscribe 'post_count', 
        #     picked_tags.array()
        #     picked_times.array()
        #     picked_locations.array()
        #     picked_authors.array()
        #     Session.get('view_videos')
        #     Session.get('view_images')
        #     Session.get('view_adult')
        # @autorun => Meteor.subscribe 'posts', 
        #     picked_tags.array()
        #     Session.get('toggle')
        #     picked_times.array()
        #     picked_locations.array()
        #     picked_authors.array()
        #     Session.get('sort_key')
        #     Session.get('sort_direction')
        #     Session.get('skip_value')
        #     Session.get('view_videos')
        #     Session.get('view_images')
        #     Session.get('view_adult')
    
    
        @autorun => Meteor.subscribe 'tags',
            picked_tags.array()
            Session.get('nsfw')
            # picked_reddit_domain.array()
            # picked_rtime_tags.array()
            # picked_subreddits.array()
            # picked_rauthors.array()
            # Session.get('toggle')
            # picked_tags.array()
            # Session.get('toggle')
            # picked_times.array()
            # picked_locations.array()
            # picked_authors.array()
            # Session.get('view_videos')
            # Session.get('view_images')
            # Session.get('view_adult')
            
        # Meteor.call 'get_reddit_latest', Router.current().params.subreddit, ->
    
        # Meteor.call 'log_reddit_view', Router.current().params.subreddit, ->

    
    Template.reddit.events
        'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
        'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
        'click .sort_up': (e,t)-> Session.set('sort_direction',1)
        'click .limit_10': (e,t)-> Session.set('limit',10)
        'click .limit_1': (e,t)-> Session.set('limit',1)
       
        'click .make_nsfw': (e,t)-> Session.set('nsfw', true)
        'click .make_safe': (e,t)-> Session.set('nsfw', false)
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
                picked_tags.push val
                # window.speechSynthesis.speak new SpeechSynthesisUtterance val
    
                $('.search_reddit').val('')
                Session.set('reddit_loading',true)
                Meteor.call 'search_reddit', val, ->
                    Session.set('reddit_loading',false)
                    Session.set('reddit_query', null)
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
             
  
    Template.unpick_tag.events
        'click .unpick':-> 
            picked_tags.remove @valueOf()
            Meteor.call 'search_reddit', picked_tags.array(), ->
            url = new URL(window.location);
            url.searchParams.set('tags', picked_tags.array());
            window.history.pushState({}, '', url);
            document.title = picked_tags.array()
            Meteor.setTimeout ->
                Session.set('toggle',!Session.get('toggle'))
            , 7000
        
  
  
    Template.reddit.helpers
        # reddit_query: -> Session.get('reddit_query')
    
        # domain_selector_class: ->
        #     if @name in picked_reddit_domain.array() then 'blue' else 'basic'
        # sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
        # sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
        # reddit_result_tags: -> results.find(model:'reddit_tag')
        # reddit_domain_tags: -> results.find(model:'reddit_domain_tag')
        # reddit_time_tags: -> results.find(model:'reddit_time_tag')
        # reddit_subreddits: -> results.find(model:'reddit_subreddit')
    
        # skip_value: -> Session.get('reddit_skip_value')
        
        # hot_class: ->
        #     if Session.equals('reddit_view_mode','hot')
        #         'black'
        #     else 
        #         'basic'
        # best_class: ->
        #     if Session.equals('reddit_view_mode','best')
        #         'black'
        #     else 
        #         'basic'
    
        picked_tags: -> picked_tags.array()
        
        # reddit_doc: ->
        #     Docs.findOne
        #         model:'subreddit'
        #         "data.display_name":Router.current().params.subreddit
        rposts: ->
            Docs.find({
                model:'rpost'
                # subreddit:Router.current().params.subreddit
            },
                sort:"#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                limit:20)
        # emotion_avg: -> results.findOne(model:'emotion_avg')
    
        # sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
        # sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
        # emotion_avg: -> results.findOne(model:'emotion_avg')
    
        # # picked_locations: -> picked_locations.array()
        # # picked_authors: -> picked_authors.array()
        # # picked_times: -> picked_times.array()
        # rpost_counter: -> Counts.get 'rpost_counter'
        
        # nightmode_class: -> if Session.get('nightmode') then 'invert'
        
        
        result_tags: -> results.find(model:'tag')
        # author_results: -> results.find(model:'author')
        # location_results: -> results.find(model:'location_tag')
        # time_results: -> results.find(model:'time_tag')
        
        # sort_points_class: -> if Session.equals('sort_key','points') then 'black' else ''
        # sort_created_class: -> if Session.equals('sort_key','data.created') then 'black' else ''
        # video_class: -> if Session.get('view_videos') then 'black' else ''
        # image_class: -> if Session.get('view_images') then 'black' else ''
        # adult_class: -> if Session.get('view_adult') then 'black' else ''
        
        # sidebar_class: -> if Session.get('view_sidebar') then 'ui four wide column' else 'hidden'
        # main_column_class: -> if Session.get('view_sidebar') then 'ui twelve wide column' else 'ui sixteen wide column' 

        is_nsfw: -> Session.get('nsfw')
                
    
    
    Template.tag_picker.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
    Template.tag_picker.helpers
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
                
                
    Template.tag_picker.events
        'click .pick_tag': -> 
            # results.update
            # console.log @
            # window.speechSynthesis.cancel()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # if @model is 'reddit_emotion'
            #     picked_emotions.push @name
            # else
            # if @model is 'reddit_tag'
            picked_tags.push @name
            $('.search_subreddit').val('')
            
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
            Session.set('reddit_loading',true)
            Meteor.call 'search_reddit', @name, ->
                Session.set('reddit_loading',false)
            Meteor.setTimeout( ->
                Session.set('toggle',!Session.get('toggle'))
            , 5000)
            
            
            
    
    
    Template.flat_tag_picker.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
    Template.flat_tag_picker.helpers
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
    Template.flat_tag_picker.events
        'click .select_flat_tag': -> 
            # results.update
            # window.speechSynthesis.cancel()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
            picked_tags.push @valueOf()
            Router.go "/r/#{Router.current().params.subreddit}/"
            $('.search_subreddit').val('')
            Session.set('loading',true)
            Meteor.call 'search_subreddit', Router.current().params.subreddit, @valueOf(), ->
                Session.set('loading',false)
            Meteor.setTimeout( ->
                Session.set('toggle',!Session.get('toggle'))
            , 3000)
            
            
            
if Meteor.isServer
    # Meteor.publish 'rpost_count', (
    #     picked_tags
    #     # picked_authors
    #     # picked_locations
    #     # picked_times
    #     )->
    #     @unblock()
    #     match = {
    #         model:'rpost'
    #         is_private:$ne:true
    #     }
    #     # unless Meteor.userId()
    #     #     match.privacy='public'
    
            
    #     if picked_tags.length > 0 then match.tags = $all:picked_tags
    #     # if picked_authors.length > 0 then match.author = $all:picked_authors
    #     # if picked_locations.length > 0 then match.location = $all:picked_locations
    #     # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    
    #     Counts.publish this, 'rpost_count', Docs.find(match)
    #     return undefined
                
    Meteor.publish 'rposts', (
        picked_tags
        nsfw
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
        if nsfw
            match['data.over_18'] = true
        else
            match['data.over_18'] = false
        
        if picked_tags.length > 0 then match.tags = $all:picked_tags
        # match.tags = $all:picked_tags
        # if picked_locations.length > 0 then match.location = $all:picked_locations
        # if picked_authors.length > 0 then match.author = $all:picked_authors
        # if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    
        # console.log 'match',match
        Docs.find match,
            limit:10
            sort:"data.ups":-1
            # sort: "#{sk}":-1
            # skip:skip*20
            fields:
                title:1
                content:1
                tags:1
                upvoter_ids:1
                image_id:1
                image_link:1
                url:1
                youtube_id:1
                _timestamp:1
                _timestamp_tags:1
                views:1
                viewer_ids:1
                _author_username:1
                downvoter_ids:1
                _author_id:1
                model:1
                data:1    
    
        
        
               
    Meteor.publish 'tags', (
        picked_tags
        nsfw
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
        if nsfw
            match['data.over_18'] = true
        else
            match['data.over_18'] = false
    
        if picked_tags.length > 0 then match.tags = $all:picked_tags
        # match.tags = $all:picked_tags
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
            # console.log tag
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
        


                    
            
            
    
                
        
    
        
        
    Meteor.methods 
        log_subreddit_view: (name)->
            sub = Docs.findOne
                model:'subreddit'
                "rdata.display_name":name
            if sub
                Docs.update sub._id,
                    $inc:dao_views:1
                    
                    
                    
               
