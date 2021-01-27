if Meteor.isClient
    @selected_dao_tags = new ReactiveArray []
    @selected_dao_time_tags = new ReactiveArray []
    @selected_dao_location_tags = new ReactiveArray []
    

    Template.dao.onRendered ->
        Meteor.call 'log_global_view'
    Template.dao.onCreated ->
        @autorun => Meteor.subscribe 'stats'
        @autorun => Meteor.subscribe 'dao_docs', 
            selected_dao_tags.array()
            selected_dao_time_tags.array()
            selected_dao_location_tags.array()
            Session.get('dao_sort_key')
            Session.get('dao_sort_direction')
            Session.get('dao_skip_value')
        @autorun => Meteor.subscribe 'dao_tags',
            selected_dao_tags.array()
            selected_dao_time_tags.array()
            selected_dao_location_tags.array()
            # selected_dao_authors.array()
            Session.get('toggle')
        @autorun => Meteor.subscribe 'dao_count', 
            selected_dao_tags.array()
            selected_dao_time_tags.array()
            selected_dao_location_tags.array()

    Template.dao_card.onCreated ->
        @autorun => Meteor.subscribe 'comments', @data._id, 
        
    Template.dao_card.events
        'click .say_title': ->
            window.speechSynthesis.speak new SpeechSynthesisUtterance @title
            window.speechSynthesis.speak new SpeechSynthesisUtterance @tags
        'click .select_time_tag': ->
            selected_dao_time_tags.push @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
    Template.post_view.events
        'click .say_title': ->
            window.speechSynthesis.speak new SpeechSynthesisUtterance @title
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @content
            window.speechSynthesis.speak new SpeechSynthesisUtterance @tags
        'click .select_time_tag': ->
            selected_dao_time_tags.push @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name

    Template.dao.events
        'click .unselect_time_tag': ->
            selected_dao_time_tags.remove @valueOf()
        'click .select_time_tag': ->
            selected_dao_time_tags.push @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            
        'click .unselect_location_tag': ->
            selected_dao_location_tags.remove @valueOf()
        'click .select_location_tag': ->
            selected_dao_location_tags.push @name
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
        'keyup .search_dao_tag': (e,t)->
             if e.which is 13
                val = t.$('.search_dao_tag').val().trim().toLowerCase()
                
                window.speechSynthesis.speak new SpeechSynthesisUtterance val

                selected_dao_tags.push val   
                t.$('.search_dao_tag').val('')
                
    Template.dao_card.events
        'keyup .add_comment': (e,t)->
             if e.which is 13
                val = t.$('.add_comment').val().trim()
                # window.speechSynthesis.speak new SpeechSynthesisUtterance val
                Docs.insert 
                    model:'comment'
                    parent_id:@_id
                    body:val
                # selected_dao_tags.push val   
                t.$('.add_comment').val('')
                
    Template.post_view.events
        'keyup .add_comment': (e,t)->
             if e.which is 13
                val = t.$('.add_comment').val().trim()
                Docs.insert 
                    model:'comment'
                    parent_id:@_id
                    body:val
                # window.speechSynthesis.speak new SpeechSynthesisUtterance val
                # selected_dao_tags.push val   
                t.$('.add_comment').val('')
                
    Template.dao.helpers
        stats: ->
            Docs.findOne
                model:'stats'
        selected_dao_tags: -> selected_dao_tags.array()
        selected_time_tags: -> selected_dao_time_tags.array()
        selected_location_tags: -> selected_dao_location_tags.array()
        selected_people_tags: -> selected_people_tags.array()
    
        dao_result_tags: -> results.find(model:'dao_tag')
        dao_time_tags: -> results.find(model:'dao_time_tag')
        dao_location_tags: -> results.find(model:'dao_location_tag')
        counter: -> Counts.get 'dao_counter'
        tribe_posts: ->
            Docs.find({
                model:'post'
                tribe:'jpfam'
            },{sort:_timestamp:-1})
    Template.dao_tag_selector.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title_small', @data.name.toLowerCase())
    Template.dao_tag_selector.helpers
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
                
                
    Template.dao_tag_selector.events
        'click .select_tag': -> 
            # results.update
            # console.log @
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # if @model is 'dao_emotion'
            #     selected_emotions.push @name
            # else
            # if @model is 'dao_tag'
            selected_dao_tags.push @name
            $('.search_subdao').val('')
            Session.set('dao_skip_value',0)
    
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
            # Session.set('dao_loading',true)
            # Meteor.call 'search_dao', @name, ->
            #     Session.set('dao_loading',false)
            # Meteor.setTimeout( ->
            #     Session.set('toggle',!Session.get('toggle'))
            # , 5000)
            
            
            
    
    Template.dao_unselect_tag.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title_small', @data.toLowerCase())
        
    Template.dao_unselect_tag.helpers
        term: ->
            found = 
                Docs.findOne 
                    # model:'wikipedia'
                    title:@valueOf().toLowerCase()
            found
    Template.dao_unselect_tag.events
        'click .unselect_dao_tag': -> 
            Session.set('skip',0)
            # console.log @
            selected_dao_tags.remove @valueOf()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
        
    
    Template.flat_dao_tag_selector.onCreated ->
        # @autorun => Meteor.subscribe('doc_by_title_small', @data.valueOf().toLowerCase())
    Template.flat_dao_tag_selector.helpers
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
    Template.flat_dao_tag_selector.events
        'click .select_flat_tag': -> 
            # results.update
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
            selected_dao_tags.push @valueOf()
            $('.search_dao').val('')

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
    Meteor.publish 'dao_count', (
        selected_tags
        selected_dao_time_tags
        selected_dao_location_tags
        )->
            
        match = {model:'post', tribe:'jpfam'}
        if selected_tags.length > 0 then match.tags = $all:selected_tags
        if selected_dao_time_tags.length > 0 then match.time_tags = $all:selected_dao_time_tags
        if selected_dao_location_tags.length > 0 then match.location_tags = $all:selected_dao_location_tags
        Counts.publish this, 'dao_counter', Docs.find(match)
        return undefined
                
    Meteor.publish 'dao_docs', (
        selected_dao_tags
        selected_dao_time_tags
        selected_dao_location_tags
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
        if selected_dao_tags.length > 0 then match.tags = $all:selected_dao_tags
        if selected_dao_time_tags.length > 0 then match.time_tags = $all:selected_dao_time_tags
        if selected_dao_location_tags.length > 0 then match.location_tags = $all:selected_dao_location_tags
        # if selected_subdao_domains.length > 0 then match.domain = $all:selected_subdao_domains
        # if selected_dao_authors.length > 0 then match.author = $all:selected_dao_authors
        console.log 'skip', skip
        Docs.find match,
            limit:20
            sort: "#{sk}":-1
            skip:skip*20
        
        
    # Meteor.methods    
        # tagify_dao: (doc_id)->
        #     doc = Docs.findOne doc_id
        #     # moment(doc.date).fromNow()
        #     # timestamp = Date.now()
    
        #     doc._timestamp_long = moment(doc._timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
        #     # doc._app = 'dao'
        
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
        #         # console.log 'dao', date_array
        #         Docs.update doc_id, 
        #             $set:addedtime_tags:date_array
        
               
    Meteor.publish 'dao_tags', (
        selected_dao_tags
        selected_dao_time_tags
        selected_dao_location_tags
        # selected_dao_authors
        # view_bounties
        # view_unanswered
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            model:'post'
            tribe:'jpfam'
            # subdao:subdao
        }
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if selected_dao_tags.length > 0 then match.tags = $all:selected_dao_tags
        # if selected_subdao_domain.length > 0 then match.domain = $all:selected_subdao_domain
        if selected_dao_time_tags.length > 0 then match.time_tags = $all:selected_dao_time_tags
        if selected_dao_location_tags.length > 0 then match.location_tags = $all:selected_dao_location_tags
        # if selected_dao_location.length > 0 then match.subdao = $all:selected_dao_location
        # if selected_dao_authors.length > 0 then match.author = $all:selected_dao_authors
        # if selected_emotion.length > 0 then match.max_emotion_name = selected_emotion
        doc_count = Docs.find(match).count()
        # console.log 'doc_count', doc_count
        dao_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_dao_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:25 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        dao_tag_cloud.forEach (tag, i) ->
            # console.log tag
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'dao_tag'
        
        
        # dao_domain_cloud = Docs.aggregate [
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
        # dao_domain_cloud.forEach (domain, i) ->
        #     self.added 'results', Random.id(),
        #         name: domain.name
        #         count: domain.count
        #         model:'dao_domain_tag'
        
        
        dao_location_cloud = Docs.aggregate [
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
        dao_location_cloud.forEach (location, i) ->
            self.added 'results', Random.id(),
                name: location.name
                count: location.count
                model:'dao_location_tag'
        
        
        
        dao_time_cloud = Docs.aggregate [
            { $match: match }
            { $project: "time_tags": 1 }
            { $unwind: "$time_tags" }
            { $group: _id: "$time_tags", count: $sum: 1 }
            { $match: _id: $nin: selected_dao_time_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:25 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        dao_time_cloud.forEach (time_tag, i) ->
            self.added 'results', Random.id(),
                name: time_tag.name
                count: time_tag.count
                model:'dao_time_tag'
      
        self.ready()
                                