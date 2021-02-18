if Meteor.isClient
    Router.route '/g/:group', (->
        @layout 'layout'
        @render 'group'
        ), name:'group'

    @group_picked_tags = new ReactiveArray []
    @group_picked_time_tags = new ReactiveArray []
    @group_picked_location_tags = new ReactiveArray []
    @group_picked_author_tags = new ReactiveArray []
    @group_picked_timestamp_tags = new ReactiveArray []


    Template.group.onCreated ->
        Session.setDefault('view_layout', 'grid')
        Session.setDefault('sort_key', '_timestamp')
        Session.setDefault('sort_direction', -1)
        Session.setDefault('view_detail', true)
        
        @autorun => Meteor.subscribe 'group_tags',
            Router.current().params.group
            group_picked_tags.array()
            group_picked_time_tags.array()
            group_picked_location_tags.array()
            group_picked_author_tags.array()
            group_picked_timestamp_tags.array()
            Session.get('toggle')
        @autorun => Meteor.subscribe 'group_count', 
            Router.current().params.group
            group_picked_tags.array()
            group_picked_time_tags.array()
            group_picked_location_tags.array()
            group_picked_author_tags.array()
            group_picked_timestamp_tags.array()
        
        @autorun => Meteor.subscribe 'group_posts', 
            Router.current().params.group
            group_picked_tags.array()
            group_picked_time_tags.array()
            group_picked_location_tags.array()
            group_picked_author_tags.array()
            group_picked_timestamp_tags.array()
            Session.get('group_sort_key')
            Session.get('sort_direction')
            Session.get('group_skip_value')
        
   

    Template.group.helpers
      
        emotion_avg: -> results.findOne(model:'emotion_avg')
        
        sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
        sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
        emotion_avg: -> results.findOne(model:'emotion_avg')
        
        counter: -> Counts.get 'counter'
    
        sort_created_class: -> if Session.equals('sort_key','data.created') then 'active' else 'tertiary'
        sort_ups_class: -> if Session.equals('sort_key','data.ups') then 'active' else 'tertiary'
      
      
        # result_tags: -> results.find(model:'tag')
        # Organizations: -> results.find(model:'Organization')
        # Companies: -> results.find(model:'Company')
        # HealthConditions: -> results.find(model:'HealthCondition')
        # Persons: -> results.find(model:'Person')
        
        time_tags: -> results.find(model:'time_tag')
        location_tags: -> results.find(model:'location_tag')
        Locations: -> results.find(model:'Location')
        authors: -> results.find(model:'author')
       
        domains: -> results.find(model:'group_domain_tag')
       
       
        current_group: -> Router.current().params.group
        posts: ->
            group_param = Router.current().params.group
            Docs.find({
                group:Router.current().params.group
                model:'post'
                # group_lowered:group_param.toLowerCase()
            },
                sort:"#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                limit:10
                skip:Session.get('skip_value')
            )
        # group_posts: ->
        #     Docs.find 
        #         model:'post'
        #         course_id:Router.current().params.group
        group_picked_tags: -> group_picked_tags.array()
        group_picked_time_tags: -> group_picked_time_tags.array()
        group_picked_locations: -> group_picked_location_tags.array()
        group_picked_people: -> group_picked_people_tags.array()
        group_picked_authors: -> group_picked_author_tags.array()
        group_picked_timestamp_tags: -> group_picked_timestamp_tags.array()
        
        counter: -> Counts.get 'counter'
        group_author_results: -> results.find(model:'group_author_tag')
        group_result_tags: -> results.find(model:'group_tag')
        time_tags: -> results.find(model:'time_tag')
        location_tags: -> results.find(model:'location_tag')
        timestamp_tags: -> results.find(model:'timestamp_tag')
        current_group: -> Router.current().params.group
            
            
            
    Template.group.events
        'click .unpick_Location': ->
            picked_Locations.remove @valueOf()
        'click .pick_Location': ->
            picked_Locations.push @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            
        'click .unpick_time_tag': ->
            group_picked_time_tags.remove @valueOf()
        'click .pick_time_tag': ->
            group_picked_time_tags.push @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            
            
        'click .unpick_timestamp_tag': ->
            group_picked_timestamp_tags.remove @valueOf()
        'click .pick_timestamp_tag': ->
            group_picked_timestamp_tags.push @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            
        'click .unpick_location_tag': ->
            group_picked_location_tags.remove @valueOf()
        'click .pick_location_tag': ->
            group_picked_location_tags.push @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
      
        'click .unpick_author': ->
            group_picked_author_tags.remove @valueOf()
        'click .pick_author': ->
            group_picked_author_tags.push @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
    
        'click .add_post': ->
            new_id = 
                Docs.insert 
                    model:'post'
                    group:Router.current().params.group
            Router.go "/g/#{Router.current().params.group}/p/#{new_id}/edit"
     
        'keyup .search_tag': (e,t)->
             if e.which is 13
                val = t.$('.search_tag').val().trim().toLowerCase()
                # window.speechSynthesis.speak new SpeechSynthesisUtterance val
                group_picked_tags.push val   
                t.$('.search_tag').val('')
                # Session.set('sub_doc_query', val)
                Session.set('loading',true)
        
            
        'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
        'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
        'click .sort_up': (e,t)-> Session.set('sort_direction',1)

        'click .set_grid': (e,t)-> Session.set('view_layout', 'grid')
        'click .set_list': (e,t)-> Session.set('view_layout', 'list')
     
    Template.group_tag_picker.onCreated ->
        # @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
        @autorun => Meteor.subscribe('model_docs', 'tip')

    Template.tip.helpers
        tips: ->
            Docs.find 
                model:'tip'
                parent_id:@_id
    Template.tip.events
        'click .tip': ->
            found_tip =
                Docs.findOne 
                    model:'tip'
                    parent_id:@_id
                    _author_id: Meteor.userId()
            if found_tip
                Docs.update found_tip._id,
                    $inc:amount:1
            else
                Docs.insert 
                    model:'tip'
                    amount:1
                    parent_id:@_id
                    _author_id: Meteor.userId()
                
            Docs.update @_id, 
                $inc:tip_total:1
            Meteor.users.update Meteor.userId(),
                $inc:points:-1
            Meteor.users.update @_author_id,
                $inc:points:1
     
    Template.group_post_card.events
        'click .view_post': (e,t)-> 
            $(e.currentTarget).closest('.card').transition('slide left')
            Router.go "/g/#{@group}/p/#{@_id}"
            # Meteor.setTimeout =>
            # , 500
            window.speechSynthesis.speak new SpeechSynthesisUtterance @title
        # 'click .call_watson': (e,t)-> 
        #     Meteor.call 'call_watson',@_id,'data.url','url',@data.url,=>
    Template.doc_item.events
        'click .view_post': (e,t)-> 
            Session.set('view_section','main')
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.title
            Router.go "/g/#{@group}/p/#{@_id}"
    
    Template.doc_item.onRendered ->
        # console.log @
        unless @data.watson
            Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
    
    # Template.post_card_small.onRendered ->
    #     # console.log @
    #     unless @data.watson
    #         Meteor.call 'call_watson',@data._id,'data.url','url',@data.data.url,=>
    #     unless @data.time_tags
    #         Meteor.call 'tagify_time_rpost',@data._id,=>
     
    # Template.post_card_small.helpers
    #     five_tags: -> @tags[..5]
     
     
     
     
     
     
     
     
     
     
     
    Template.group_tag_picker.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
    Template.group_tag_picker.helpers
        picker_class: ()->
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
            res = 
                Docs.findOne 
                    title:@name.toLowerCase()
            # console.log res
            res
         
         
         
         
    Template.group_tag_picker.events
        'click .pick_tag': -> 
            # results.update
            # console.log @
            group_picked_tags.push @name
            $('.search_tag').val('')
            Session.set('skip_value',0)
    
            
            
            
    
    Template.group_unpick_tag.onCreated ->
        # @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
        
    Template.group_unpick_tag.helpers
        term: ->
            found = 
                Docs.findOne 
                    # model:'wikipedia'
                    title:@valueOf().toLowerCase()
            found
            
            
    Template.group_unpick_tag.events
        'click .group_unpick_tag': -> 
            Session.set('skip',0)
            # console.log @
            group_picked_tags.remove @valueOf()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance picked_tags.array().toString()
        
    
    Template.group_flat_tag_picker.onCreated ->
        # @autorun => Meteor.subscribe('doc_by_title', @data.valueOf().toLowerCase())
    Template.group_flat_tag_picker.helpers
        picker_class: ()->
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
    Template.group_flat_tag_picker.events
        'click .pick_flat_tag': -> 
            # results.update
            # window.speechSynthesis.cancel()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
            group_picked_tags.push @valueOf()
            $('.search_group').val('')
            # Router.go "/g/#{Router.current().params.group}"






if Meteor.isServer
    Meteor.publish 'post_tips', (parent_id)->
        Docs.find 
            model:'tip'
            parent_id:parent_id
    Meteor.publish 'group_count', (
        group
        group_picked_tags
        group_picked_time_tags
        group_picked_location_tags
        group_picked_author_tags
        group_picked_timestamp_tags
        )->
        match = {model:'post'}
        match.group = group
            
        if group_picked_tags.length > 0 then match.tags = $all:group_picked_tags
        if group_picked_time_tags.length > 0 then match.time_tags = $all:group_picked_time_tags
        if group_picked_location_tags.length > 0 then match.location_tags = $all:group_picked_location_tags
        if group_picked_author_tags.length > 0 then match._author_username = $all:group_picked_author_tags
        if group_picked_timestamp_tags.length > 0 then match.timestamp_tags = $all:group_picked_timestamp_tags

        Counts.publish this, 'counter', Docs.find(match)
        return undefined
                
    Meteor.publish 'group_posts', (
        group
        group_picked_tags
        group_picked_time_tags
        group_picked_location_tags
        group_picked_author_tags
        group_picked_timestamp_tags
        sort_key
        sort_direction=-1
        skip=0
        )->
        self = @
        match = {
            model:'post'
            # group: group
        }
        match.group = group

        if sort_key
            sk = sort_key
        else
            sk = '_timestamp'
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if group_picked_tags.length > 0 then match.tags = $all:group_picked_tags
        if group_picked_time_tags.length > 0 then match.time_tags = $all:group_picked_time_tags
        if group_picked_location_tags.length > 0 then match.location_tags = $all:group_picked_location_tags
        if group_picked_author_tags.length > 0 then match._author_username = $all:group_picked_author_tags
        if group_picked_timestamp_tags.length > 0 then match.timestamp_tags = $all:group_picked_timestamp_tags
        # if selected_group_authors.length > 0 then match.author = $all:selected_group_authors
        # console.log 'skip', skip
        Docs.find match,
            limit:20
            sort: "#{sk}":parseInt(sort_direction)
            # skip:skip*20
            fields:
                title:1
                content:1
                tags:1
                time_tags:1
                image_id:1
                group:1
                model:1
                _author_username:1
                _timestamp:1
                timestamp_tags:1
                doc_sentiment_label:1
                joy_percent:1
                sadness_percent:1        
                fear_percent:1        
                disgust_percent:1        
                anger_percent:1        
                youtube_id:1
                downvoter_ids:1
                upvoter_ids:1
                tip_total:1
                points:1
                doc_sentiment_score:1
        
    # Meteor.methods    
        # tagify_group: (group)->
        #     doc = Docs.findOne group
        #     # moment(doc.date).fromNow()
        #     # timestamp = Date.now()
    
        #     doc._timestamp_long = moment(doc._timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
        #     # doc._app = 'group'
        
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
        #         doc._timestamp_tags = date_array
        #         # console.log 'group', date_array
        #         Docs.update group, 
        #             $set:addedtime_tags:date_array
        
               
    Meteor.publish 'group_tags', (
        group
        group_picked_tags
        group_picked_time_tags
        group_picked_location_tags
        group_picked_author_tags
        group_picked_timestamp_tags
        # selected_group_authors
        # view_bounties
        # view_unanswered
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            model:'post'
            # group:group
            # subgroup:subgroup
        }
        match.group = group

        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if group_picked_tags.length > 0 then match.tags = $all:group_picked_tags
        # if selected_subgroup_domain.length > 0 then match.domain = $all:selected_subgroup_domain
        if group_picked_time_tags.length > 0 then match.time_tags = $all:group_picked_time_tags
        if group_picked_location_tags.length > 0 then match.location_tags = $all:group_picked_location_tags
        if group_picked_author_tags.length > 0 then match._author_username = $all:group_picked_author_tags
        if group_picked_timestamp_tags.length > 0 then match.timestamp_tags = $all:group_picked_timestamp_tags
        # if selected_group_location.length > 0 then match.subgroup = $all:selected_group_location
        # if selected_group_authors.length > 0 then match.author = $all:selected_group_authors
        # if selected_emotion.length > 0 then match.max_emotion_name = selected_emotion
        doc_count = Docs.find(match).count()
        # console.log 'doc_count', doc_count
        group_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: group_picked_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:33 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        group_tag_cloud.forEach (tag, i) ->
            # console.log tag
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'group_tag'
        
        
        group_author_cloud = Docs.aggregate [
            { $match: match }
            { $project: "_author_username": 1 }
            # { $unwind: "$author" }
            { $group: _id: "$_author_username", count: $sum: 1 }
            # { $match: _id: $nin: selected_authors }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        group_author_cloud.forEach (author, i) ->
            self.added 'results', Random.id(),
                name: author.name
                count: author.count
                model:'group_author_tag'
        
        
        group_location_cloud = Docs.aggregate [
            { $match: match }
            { $project: "location_tags": 1 }
            { $unwind: "$location_tags" }
            { $group: _id: "$location_tags", count: $sum: 1 }
            # { $match: _id: $nin: selected_location }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        group_location_cloud.forEach (location, i) ->
            self.added 'results', Random.id(),
                name: location.name
                count: location.count
                model:'location_tag'
        
        
        
        group_time_cloud = Docs.aggregate [
            { $match: match }
            { $project: "time_tags": 1 }
            { $unwind: "$time_tags" }
            { $group: _id: "$time_tags", count: $sum: 1 }
            { $match: _id: $nin: group_picked_time_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        group_time_cloud.forEach (time_tag, i) ->
            self.added 'results', Random.id(),
                name: time_tag.name
                count: time_tag.count
                model:'time_tag'
      
      
        group_timestamp_cloud = Docs.aggregate [
            { $match: match }
            { $project: "timestamp_tags": 1 }
            { $unwind: "$timestamp_tags" }
            { $group: _id: "$timestamp_tags", count: $sum: 1 }
            { $match: _id: $nin: group_picked_timestamp_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        group_timestamp_cloud.forEach (timestamp_tag, i) ->
            self.added 'results', Random.id(),
                name: timestamp_tag.name
                count: timestamp_tag.count
                model:'timestamp_tag'
      
        self.ready()
            
