if Meteor.isClient
    @selected_home_tags = new ReactiveArray []
    @selected_home_time_tags = new ReactiveArray []
    @selected_home_location_tags = new ReactiveArray []
    

    Template.home.onRendered ->
        Meteor.call 'log_global_view'
    Template.home.onCreated ->
        @autorun => Meteor.subscribe 'stats'
        @autorun => Meteor.subscribe 'home_docs', 
            selected_home_tags.array()
            selected_home_time_tags.array()
            selected_home_location_tags.array()
            Session.get('home_sort_key')
            Session.get('home_sort_direction')
            Session.get('home_skip_value')
        @autorun => Meteor.subscribe 'home_tags',
            selected_home_tags.array()
            selected_home_time_tags.array()
            selected_home_location_tags.array()
            # selected_home_authors.array()
            Session.get('toggle')
        @autorun => Meteor.subscribe 'home_count', 
            selected_home_tags.array()
            selected_home_time_tags.array()
            selected_home_location_tags.array()

    Template.home_card.onCreated ->
        @autorun => Meteor.subscribe 'comments', @data._id, 
        
    Template.home_card.events
        'click .say_title': ->
            window.speechSynthesis.speak new SpeechSynthesisUtterance @title
            window.speechSynthesis.speak new SpeechSynthesisUtterance @tags
        'click .select_time_tag': ->
            selected_home_time_tags.push @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name

    Template.home.events
        'click .unselect_time_tag': ->
            selected_home_time_tags.remove @valueOf()
        'click .select_time_tag': ->
            selected_home_time_tags.push @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            
        'click .unselect_location_tag': ->
            selected_home_location_tags.remove @valueOf()
        'click .select_location_tag': ->
            selected_home_location_tags.push @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name

            
        'click .add_fam_post': (e,t)->
            # if e.which is 13
                # val = $('.add_fam_post').val()
            new_id = 
                Docs.insert 
                    model:'post'
                    tribe:'jpfam'
                    # title:val
            Router.go "/p/#{new_id}/edit"        
                    
            # $('.add_fam_post').val('')
        'keyup .search_home_tag': (e,t)->
             if e.which is 13
                val = t.$('.search_home_tag').val().trim().toLowerCase()
                
                window.speechSynthesis.speak new SpeechSynthesisUtterance val

                selected_home_tags.push val   
                t.$('.search_home_tag').val('')
                
    Template.home_card.events
        'keyup .add_comment': (e,t)->
             if e.which is 13
                val = t.$('.add_comment').val().trim()
                # window.speechSynthesis.speak new SpeechSynthesisUtterance val
                Docs.insert 
                    model:'comment'
                    parent_id:@_id
                    body:val
                # selected_home_tags.push val   
                t.$('.add_comment').val('')
                
    Template.home.helpers
        stats: ->
            Docs.findOne
                model:'stats'
        selected_home_tags: -> selected_home_tags.array()
        selected_time_tags: -> selected_home_time_tags.array()
        selected_location_tags: -> selected_home_location_tags.array()
        selected_people_tags: -> selected_people_tags.array()
    
        home_result_tags: -> results.find(model:'home_tag')
        home_time_tags: -> results.find(model:'home_time_tag')
        home_location_tags: -> results.find(model:'home_location_tag')
        counter: -> Counts.get 'home_counter'
        tribe_posts: ->
            Docs.find({
                model:'post'
                tribe:'jpfam'
            },{sort:_timestamp:-1})
    Template.home_tag_selector.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title_small', @data.name.toLowerCase())
    Template.home_tag_selector.helpers
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
                
                
    Template.home_tag_selector.events
        'click .select_tag': -> 
            # results.update
            # console.log @
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # if @model is 'home_emotion'
            #     selected_emotions.push @name
            # else
            # if @model is 'home_tag'
            selected_home_tags.push @name
            $('.search_subhome').val('')
            Session.set('home_skip_value',0)
    
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
            # Session.set('home_loading',true)
            # Meteor.call 'search_home', @name, ->
            #     Session.set('home_loading',false)
            # Meteor.setTimeout( ->
            #     Session.set('toggle',!Session.get('toggle'))
            # , 5000)
            
            
            
    
    Template.home_unselect_tag.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title_small', @data.toLowerCase())
        
    Template.home_unselect_tag.helpers
        term: ->
            found = 
                Docs.findOne 
                    # model:'wikipedia'
                    title:@valueOf().toLowerCase()
            found
    Template.home_unselect_tag.events
        'click .unselect_home_tag': -> 
            Session.set('skip',0)
            # console.log @
            selected_home_tags.remove @valueOf()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
        
    
    Template.flat_home_tag_selector.onCreated ->
        # @autorun => Meteor.subscribe('doc_by_title_small', @data.valueOf().toLowerCase())
    Template.flat_home_tag_selector.helpers
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
    Template.flat_home_tag_selector.events
        'click .select_flat_tag': -> 
            # results.update
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
            selected_home_tags.push @valueOf()
            $('.search_home').val('')

if Meteor.isServer 
    # Meteor.publish 'fam_posts', ->
    #     Docs.find 
    #         model:'post'
    #         tribe:'jpfam'
            
    Meteor.methods
        log_global_view: ->
            found = 
                Docs.findOne 
                    model:'stats'
            if found 
                Docs.update found._id, 
                    $inc:home_views:1
            else
                Docs.insert 
                    model:'stats'
                    home_views:1
                
    Meteor.publish 'stats', (doc_id)->
        Docs.find
            model:'stats'
    Meteor.publish 'comments', (doc_id)->
        Docs.find
            model:'comment'
            parent_id:doc_id
    Meteor.publish 'home_count', (
        selected_tags
        selected_home_time_tags
        selected_home_location_tags
        )->
            
        match = {model:'post', tribe:'jpfam'}
        if selected_tags.length > 0 then match.tags = $all:selected_tags
        if selected_home_time_tags.length > 0 then match.time_tags = $all:selected_home_time_tags
        if selected_home_location_tags.length > 0 then match.location_tags = $all:selected_home_location_tags
        Counts.publish this, 'home_counter', Docs.find(match)
        return undefined
                
    Meteor.publish 'home_docs', (
        selected_home_tags
        selected_home_time_tags
        selected_home_location_tags
        sort_key
        sort_direction
        skip=0
        )->
        self = @
        match = {
            model:'post'
            tribe:'jpfam'
        }
        if sort_key
            sk = sort_key
        else
            sk = '_timestamp'
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if selected_home_tags.length > 0 then match.tags = $all:selected_home_tags
        if selected_home_time_tags.length > 0 then match.time_tags = $all:selected_home_time_tags
        if selected_home_location_tags.length > 0 then match.location_tags = $all:selected_home_location_tags
        # if selected_subhome_domains.length > 0 then match.domain = $all:selected_subhome_domains
        # if selected_home_authors.length > 0 then match.author = $all:selected_home_authors
        console.log 'skip', skip
        Docs.find match,
            limit:20
            sort: "#{sk}":-1
            skip:skip*20
        
        
    # Meteor.methods    
        # tagify_home: (doc_id)->
        #     doc = Docs.findOne doc_id
        #     # moment(doc.date).fromNow()
        #     # timestamp = Date.now()
    
        #     doc._timestamp_long = moment(doc._timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
        #     # doc._app = 'home'
        
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
        #         # console.log 'home', date_array
        #         Docs.update doc_id, 
        #             $set:addedtime_tags:date_array
        
               
    Meteor.publish 'home_tags', (
        selected_home_tags
        selected_home_time_tags
        selected_home_location_tags
        # selected_home_authors
        # view_bounties
        # view_unanswered
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            model:'post'
            tribe:'jpfam'
            # subhome:subhome
        }
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if selected_home_tags.length > 0 then match.tags = $all:selected_home_tags
        # if selected_subhome_domain.length > 0 then match.domain = $all:selected_subhome_domain
        if selected_home_time_tags.length > 0 then match.time_tags = $all:selected_home_time_tags
        if selected_home_location_tags.length > 0 then match.location_tags = $all:selected_home_location_tags
        # if selected_home_location.length > 0 then match.subhome = $all:selected_home_location
        # if selected_home_authors.length > 0 then match.author = $all:selected_home_authors
        # if selected_emotion.length > 0 then match.max_emotion_name = selected_emotion
        doc_count = Docs.find(match).count()
        # console.log 'doc_count', doc_count
        home_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_home_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:25 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        home_tag_cloud.forEach (tag, i) ->
            # console.log tag
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'home_tag'
        
        
        # home_domain_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "data.domain": 1 }
        #     # { $unwind: "$domain" }
        #     { $group: _id: "$data.domain", count: $sum: 1 }
        #     # { $match: _id: $nin: selected_domains }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: doc_count }
        #     { $limit:10 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ]
        # home_domain_cloud.forEach (domain, i) ->
        #     self.added 'results', Random.id(),
        #         name: domain.name
        #         count: domain.count
        #         model:'home_domain_tag'
        
        
        home_location_cloud = Docs.aggregate [
            { $match: match }
            { $project: "location_tags": 1 }
            { $unwind: "$location_tags" }
            { $group: _id: "$location_tags", count: $sum: 1 }
            # { $match: _id: $nin: selected_location }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:25 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        home_location_cloud.forEach (location, i) ->
            self.added 'results', Random.id(),
                name: location.name
                count: location.count
                model:'home_location_tag'
        
        
        
        home_time_cloud = Docs.aggregate [
            { $match: match }
            { $project: "time_tags": 1 }
            { $unwind: "$time_tags" }
            { $group: _id: "$time_tags", count: $sum: 1 }
            { $match: _id: $nin: selected_home_time_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:25 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        home_time_cloud.forEach (time_tag, i) ->
            self.added 'results', Random.id(),
                name: time_tag.name
                count: time_tag.count
                model:'home_time_tag'
      
        self.ready()
                                