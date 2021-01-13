if Meteor.isClient
    @selected_family_tags = new ReactiveArray []
    @selected_family_time_tags = new ReactiveArray []
    @selected_family_location_tags = new ReactiveArray []
    

    Template.family.onCreated ->
        @autorun => Meteor.subscribe 'fam_posts'
        @autorun => Meteor.subscribe 'family_docs', 
            selected_family_tags.array()
            selected_family_time_tags.array()
            selected_family_location_tags.array()
            Session.get('family_sort_key')
            Session.get('family_sort_direction')
            Session.get('family_skip_value')
        @autorun => Meteor.subscribe 'family_tags',
            selected_family_tags.array()
            selected_family_time_tags.array()
            selected_family_location_tags.array()
            # selected_family_authors.array()
            Session.get('toggle')
        @autorun => Meteor.subscribe 'family_count', 
            selected_family_tags.array()
            selected_family_time_tags.array()
            selected_family_location_tags.array()

    Template.family.events
        'keyup .add_fam_post': (e,t)->
            if e.which is 13
                val = $('.add_fam_post').val()
                Docs.insert 
                    model:'post'
                    tribe:'jpfam'
                    title:val
                $('.add_fam_post').val('')
                
                
    Template.family.helpers
        selected_family_tags: -> selected_family_tags.array()
        selected_time_tags_tags: -> selected_family_time_tags.array()
        selected_location_tags_tags: -> selected_family_location_tags.array()
        selected_people_tags_tags: -> selected_people_tags.array()
    
        family_result_tags: -> results.find(model:'family_tag')
        family_time_tags: -> results.find(model:'family_time_tag')
        family_location_tags: -> results.find(model:'family_location_tag')
    
        tribe_posts: ->
            Docs.find 
                model:'post'
                tribe:'jpfam'
    Template.family_tag_selector.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title_small', @data.name.toLowerCase())
    Template.family_tag_selector.helpers
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
                
                
    Template.family_tag_selector.events
        'click .select_tag': -> 
            # results.update
            # console.log @
            # window.speechSynthesis.cancel()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # if @model is 'family_emotion'
            #     selected_emotions.push @name
            # else
            # if @model is 'family_tag'
            selected_family_tags.push @name
            $('.search_subfamily').val('')
            Session.set('family_skip_value',0)
    
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
            # Session.set('family_loading',true)
            # Meteor.call 'search_family', @name, ->
            #     Session.set('family_loading',false)
            # Meteor.setTimeout( ->
            #     Session.set('toggle',!Session.get('toggle'))
            # , 5000)
            
            
            
    
    Template.family_unselect_tag.onCreated ->
        
        @autorun => Meteor.subscribe('doc_by_title_small', @data.toLowerCase())
        
    Template.family_unselect_tag.helpers
        term: ->
            found = 
                Docs.findOne 
                    # model:'wikipedia'
                    title:@valueOf().toLowerCase()
            found
    Template.family_unselect_tag.events
        'click .unselect_family_tag': -> 
            Session.set('skip',0)
            # console.log @
            selected_family_tags.remove @valueOf()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
        
    
    Template.flat_family_tag_selector.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title_small', @data.valueOf().toLowerCase())
    Template.flat_family_tag_selector.helpers
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
    Template.flat_family_tag_selector.events
        'click .select_flat_tag': -> 
            # results.update
            # window.speechSynthesis.cancel()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
            selected_family_tags.push @valueOf()
            $('.search_family').val('')
            # Session.set('family_loading',true)
            # Meteor.call 'search_subfamily', Router.current().params.subfamily, @valueOf(), ->
            #     Session.set('loading',false)
            # Meteor.setTimeout( ->
            #     Session.set('toggle',!Session.get('toggle'))
            # , 3000)

if Meteor.isServer 
    # Meteor.publish 'fam_posts', ->
    #     Docs.find 
    #         model:'post'
    #         tribe:'jpfam'
            
    Meteor.publish 'family_count', (
        selected_tags
        selected_family_time_tags
        selected_family_location_tags
        )->
            
        match = {model:'family'}
        if selected_tags.length > 0 then match.tags = $all:selected_tags
        if selected_family_time_tags.length > 0 then match.time_tags = $all:selected_family_time_tags
        if selected_family_location_tags.length > 0 then match.location_tags = $all:selected_family_location_tags
        Counts.publish this, 'family_counter', Docs.find(match)
        return undefined
                
    Meteor.publish 'family_docs', (
        selected_family_tags
        selected_family_time_tags
        selected_family_location_tags
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
            sk = 'date'
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if selected_family_tags.length > 0 then match.tags = $all:selected_family_tags
        if selected_family_time_tags.length > 0 then match.time_tags = $all:selected_family_time_tags
        if selected_family_location_tags.length > 0 then match.location_tags = $all:selected_family_location_tags
        # if selected_subfamily_domains.length > 0 then match.domain = $all:selected_subfamily_domains
        # if selected_family_authors.length > 0 then match.author = $all:selected_family_authors
        console.log 'skip', skip
        Docs.find match,
            limit:20
            sort: "#{sk}":-1
            skip:skip*20
        
        
    Meteor.methods    
        # tagify_family: (doc_id)->
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
        #         # console.log 'family', date_array
        #         Docs.update doc_id, 
        #             $set:addedtime_tags:date_array
        
               
    Meteor.publish 'family_tags', (
        selected_family_tags
        selected_family_time_tags
        selected_family_location_tags
        # selected_family_authors
        # view_bounties
        # view_unanswered
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            model:'post'
            tribe:'jpfam'
            # subfamily:subfamily
        }
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if selected_family_tags.length > 0 then match.tags = $all:selected_family_tags
        # if selected_subfamily_domain.length > 0 then match.domain = $all:selected_subfamily_domain
        if selected_family_time_tags.length > 0 then match.time_tags = $all:selected_family_time_tags
        if selected_family_location_tags.length > 0 then match.location_tags = $all:selected_family_location_tags
        # if selected_family_location.length > 0 then match.subfamily = $all:selected_family_location
        # if selected_family_authors.length > 0 then match.author = $all:selected_family_authors
        # if selected_emotion.length > 0 then match.max_emotion_name = selected_emotion
        doc_count = Docs.find(match).count()
        # console.log 'doc_count', doc_count
        family_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_family_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        family_tag_cloud.forEach (tag, i) ->
            # console.log tag
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'family_tag'
        
        
        # family_domain_cloud = Docs.aggregate [
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
        # family_domain_cloud.forEach (domain, i) ->
        #     self.added 'results', Random.id(),
        #         name: domain.name
        #         count: domain.count
        #         model:'family_domain_tag'
        
        
        family_location_cloud = Docs.aggregate [
            { $match: match }
            { $project: "location_tags": 1 }
            { $unwind: "$location_tags" }
            { $group: _id: "$location_tags", count: $sum: 1 }
            # { $match: _id: $nin: selected_location }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        family_location_cloud.forEach (location, i) ->
            self.added 'results', Random.id(),
                name: location.name
                count: location.count
                model:'family_location_tag'
        
        
        
        family_time_cloud = Docs.aggregate [
            { $match: match }
            { $project: "time_tags": 1 }
            { $unwind: "$time_tags" }
            { $group: _id: "$time_tags", count: $sum: 1 }
            { $match: _id: $nin: selected_family_time_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        family_time_cloud.forEach (time_tag, i) ->
            self.added 'results', Random.id(),
                name: time_tag.name
                count: time_tag.count
                model:'family_time_tag'
      
        self.ready()
                                