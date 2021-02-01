if Meteor.isClient
    Router.route '/group/:doc_id', (->
        @layout 'layout'
        @render 'group_home'
        ), name:'group_home'
    Router.route '/:slug', (->
        @layout 'layout'
        @render 'group_home'
        ), name:'slug_home'
    Router.route '/course/:doc_id', (->
        @layout 'layout'
        @render 'group_home'
        ), name:'course_home'

    @selected_group_tags = new ReactiveArray []
    @selected_group_time_tags = new ReactiveArray []
    @selected_group_location_tags = new ReactiveArray []


        
   
   
    Router.route '/group/:doc_id/edit', (->
        @layout 'layout'
        @render 'group_edit'
        ), name:'group_edit'

    Template.group_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.group_edit.onRendered ->



    Template.group_home.onCreated ->
        if Router.current().params.doc_id
            @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        if Router.current().params.slug
            @autorun => Meteor.subscribe 'doc_from_slug', Router.current().params.slug
        # @autorun => Meteor.subscribe 'shop_from_group_slug', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_tags',
            Router.current().params.doc_id
            selected_group_tags.array()
            selected_group_time_tags.array()
            selected_group_location_tags.array()
            # selected_group_authors.array()
            Session.get('toggle')
        @autorun => Meteor.subscribe 'group_count', 
            Router.current().params.doc_id
            selected_group_tags.array()
            selected_group_time_tags.array()
            selected_group_location_tags.array()
        
        @autorun => Meteor.subscribe 'group_posts', 
            Router.current().params.doc_id
            selected_group_tags.array()
            selected_group_time_tags.array()
            selected_group_location_tags.array()
            Session.get('group_sort_key')
            Session.get('group_sort_direction')
            Session.get('group_skip_value')

    Template.group_home.helpers
        group_posts: ->
            if Router.current().params.slug is 'all'
                Docs.find 
                    model:'post'
                    group_slug:$exists:false
            else
                Docs.find 
                    model:'post'
                    group_slug:Router.current().params.slug
                    
        # group_posts: ->
        #     Docs.find 
        #         model:'post'
        #         course_id:Router.current().params.doc_id
        selected_group_tags: -> selected_group_tags.array()
        selected_time_tags: -> selected_group_time_tags.array()
        selected_location_tags: -> selected_group_location_tags.array()
        selected_people_tags: -> selected_people_tags.array()
        counter: -> Counts.get 'group_counter'
        group_result_tags: -> results.find(model:'group_tag')
        group_time_tags: -> results.find(model:'group_time_tag')
        group_location_tags: -> results.find(model:'group_location_tag')
        current_slug: ->
            Router.current().params.slug
        group_doc: ->
            Docs.findOne    
                model:'group'
                slug:Router.current().params.slug
            
    Template.group_home.events
        'click .create_group': ->
            Docs.insert    
                model:'group'
                slug:Router.current().params.slug
            
        # 'click .unselect_group_tag': -> 
        #     Session.set('skip',0)
        #     # console.log @
        #     selected_group_tags.remove @valueOf()
        #     # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
    
        # 'click .select_tag': -> 
        #     # results.update
        #     # console.log @
        #     # window.speechSynthesis.cancel()
        #     window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        #     # if @model is 'group_emotion'
        #     #     selected_emotions.push @name
        #     # else
        #     # if @model is 'group_tag'
        #     selected_group_tags.push @name
        #     $('.search_subgroup').val('')
        #     Session.set('group_skip_value',0)
    
        'click .unselect_time_tag': ->
            selected_group_time_tags.remove @valueOf()
        'click .select_time_tag': ->
            selected_group_time_tags.push @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            
        'click .unselect_location_tag': ->
            selected_group_location_tags.remove @valueOf()
        'click .select_location_tag': ->
            selected_group_location_tags.push @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
    
        'click .add_post': ->
            new_id = 
                Docs.insert 
                    model:'post'
                    course_id:Router.current().params.doc_id
            Router.go "/group/#{Router.current().params.doc_id}/post/#{new_id}/edit"
        'keyup .search_group_tag': (e,t)->
             if e.which is 13
                val = t.$('.search_group_tag').val().trim().toLowerCase()
                window.speechSynthesis.speak new SpeechSynthesisUtterance val
                selected_group_tags.push val   
                t.$('.search_group_tag').val('')
            
            
    Template.group_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        # 'click .publish': ->
        #     Docs.update Router.current().params.doc_id,
        #         $set:published:true
        #     if confirm 'confirm?'
        #         Meteor.call 'publish_menu', @_id, =>
        #             Router.go "/menu/#{@_id}/view"


    Template.group_tag_selector.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title_small', @data.name.toLowerCase())
    Template.group_tag_selector.helpers
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
            res = 
                Docs.findOne 
                    title:@name.toLowerCase()
            # console.log res
            res
                
    Template.group_tag_selector.events
        'click .select_tag': -> 
            # results.update
            # console.log @
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # if @model is 'group_emotion'
            #     selected_emotions.push @name
            # else
            # if @model is 'group_tag'
            selected_group_tags.push @name
            $('.search_subgroup').val('')
            Session.set('group_skip_value',0)
    
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
            # Session.set('group_loading',true)
            # Meteor.call 'search_group', @name, ->
            #     Session.set('group_loading',false)
            # Meteor.setTimeout( ->
            #     Session.set('toggle',!Session.get('toggle'))
            # , 5000)
            
            
            
    
    Template.group_unselect_tag.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title_small', @data.toLowerCase())
        
    Template.group_unselect_tag.helpers
        term: ->
            found = 
                Docs.findOne 
                    # model:'wikipedia'
                    title:@valueOf().toLowerCase()
            found
    Template.group_unselect_tag.events
        'click .unselect_group_tag': -> 
            Session.set('skip',0)
            # console.log @
            selected_group_tags.remove @valueOf()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
        
    
    Template.flat_group_tag_selector.onCreated ->
        # @autorun => Meteor.subscribe('doc_by_title_small', @data.valueOf().toLowerCase())
    Template.flat_group_tag_selector.helpers
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
    Template.flat_group_tag_selector.events
        'click .select_flat_tag': -> 
            # results.update
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
            selected_group_tags.push @valueOf()
            $('.search_group').val('')




if Meteor.isServer
    Meteor.publish 'doc_from_slug', (slug)->
        Docs.find
            model:'group'
            slug:slug
    Meteor.publish 'group_count', (
        group_slug
        selected_tags
        selected_group_time_tags
        selected_group_location_tags
        )->
        match = {model:'post'}
        if group_slug is 'all'
            match.group_slug = $exists:false
        else
            match.group_slug = group_slug
            
        if selected_tags.length > 0 then match.tags = $all:selected_tags
        if selected_group_time_tags.length > 0 then match.time_tags = $all:selected_group_time_tags
        if selected_group_location_tags.length > 0 then match.location_tags = $all:selected_group_location_tags
        Counts.publish this, 'group_counter', Docs.find(match)
        return undefined
                
    Meteor.publish 'group_posts', (
        group_slug
        selected_group_tags
        selected_group_time_tags
        selected_group_location_tags
        sort_key
        sort_direction
        skip=0
        )->
        self = @
        match = {
            model:'post'
            # group_slug: group_slug
        }
        if group_slug is 'all'
            match.group_slug = $exists:false
        else
            match.group_slug = group_slug

        if sort_key
            sk = sort_key
        else
            sk = '_timestamp'
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if selected_group_tags.length > 0 then match.tags = $all:selected_group_tags
        if selected_group_time_tags.length > 0 then match.time_tags = $all:selected_group_time_tags
        if selected_group_location_tags.length > 0 then match.location_tags = $all:selected_group_location_tags
        # if selected_subgroup_domains.length > 0 then match.domain = $all:selected_subgroup_domains
        # if selected_group_authors.length > 0 then match.author = $all:selected_group_authors
        console.log 'skip', skip
        Docs.find match,
            limit:20
            sort: "#{sk}":-1
            skip:skip*20
        
        
    # Meteor.methods    
        # tagify_group: (doc_id)->
        #     doc = Docs.findOne doc_id
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
        #         Docs.update doc_id, 
        #             $set:addedtime_tags:date_array
        
               
    Meteor.publish 'group_tags', (
        group_slug
        selected_group_tags
        selected_group_time_tags
        selected_group_location_tags
        # selected_group_authors
        # view_bounties
        # view_unanswered
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            model:'post'
            # group_slug:group_slug
            # subgroup:subgroup
        }
        if group_slug is 'all'
            match.group_slug = $exists:false
        else
            match.group_slug = group_slug

        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if selected_group_tags.length > 0 then match.tags = $all:selected_group_tags
        # if selected_subgroup_domain.length > 0 then match.domain = $all:selected_subgroup_domain
        if selected_group_time_tags.length > 0 then match.time_tags = $all:selected_group_time_tags
        if selected_group_location_tags.length > 0 then match.location_tags = $all:selected_group_location_tags
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
            { $match: _id: $nin: selected_group_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:25 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        group_tag_cloud.forEach (tag, i) ->
            # console.log tag
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'group_tag'
        
        
        # group_domain_cloud = Docs.aggregate [
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
        # group_domain_cloud.forEach (domain, i) ->
        #     self.added 'results', Random.id(),
        #         name: domain.name
        #         count: domain.count
        #         model:'group_domain_tag'
        
        
        group_location_cloud = Docs.aggregate [
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
        group_location_cloud.forEach (location, i) ->
            self.added 'results', Random.id(),
                name: location.name
                count: location.count
                model:'group_location_tag'
        
        
        
        group_time_cloud = Docs.aggregate [
            { $match: match }
            { $project: "time_tags": 1 }
            { $unwind: "$time_tags" }
            { $group: _id: "$time_tags", count: $sum: 1 }
            { $match: _id: $nin: selected_group_time_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:25 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        group_time_cloud.forEach (time_tag, i) ->
            self.added 'results', Random.id(),
                name: time_tag.name
                count: time_tag.count
                model:'group_time_tag'
      
        self.ready()
            