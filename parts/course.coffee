if Meteor.isClient
    Router.route '/course/:doc_id', (->
        @layout 'layout'
        @render 'course_home'
        ), name:'course_home'

    @selected_course_tags = new ReactiveArray []
    @selected_course_time_tags = new ReactiveArray []
    @selected_course_location_tags = new ReactiveArray []


        
    Template.course_home.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'shop_from_course_id', Router.current().params.doc_id
   
   
    Router.route '/course/:doc_id/edit', (->
        @layout 'layout'
        @render 'course_edit'
        ), name:'course_edit'

    Template.course_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.course_edit.onRendered ->



    Template.course_home.onCreated ->
        @autorun => Meteor.subscribe 'course_tags',
            Router.current().params.doc_id
            selected_course_tags.array()
            selected_course_time_tags.array()
            selected_course_location_tags.array()
            # selected_course_authors.array()
            Session.get('toggle')
        @autorun => Meteor.subscribe 'course_count', 
            Router.current().params.doc_id
            selected_course_tags.array()
            selected_course_time_tags.array()
            selected_course_location_tags.array()
        
        @autorun => Meteor.subscribe 'course_posts', 
            Router.current().params.doc_id
            selected_course_tags.array()
            selected_course_time_tags.array()
            selected_course_location_tags.array()
            Session.get('course_sort_key')
            Session.get('course_sort_direction')
            Session.get('course_skip_value')

    Template.course_home.helpers
        course_posts: ->
            Docs.find 
                model:'post'
                course_id:Router.current().params.doc_id
        selected_course_tags: -> selected_course_tags.array()
        selected_time_tags: -> selected_course_time_tags.array()
        selected_location_tags: -> selected_course_location_tags.array()
        selected_people_tags: -> selected_people_tags.array()
        counter: -> Counts.get 'course_counter'
        course_result_tags: -> results.find(model:'course_tag')
        course_time_tags: -> results.find(model:'course_time_tag')
        course_location_tags: -> results.find(model:'course_location_tag')

            
    Template.course_home.events
        # 'click .unselect_course_tag': -> 
        #     Session.set('skip',0)
        #     # console.log @
        #     selected_course_tags.remove @valueOf()
        #     # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
    
        # 'click .select_tag': -> 
        #     # results.update
        #     # console.log @
        #     # window.speechSynthesis.cancel()
        #     window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        #     # if @model is 'course_emotion'
        #     #     selected_emotions.push @name
        #     # else
        #     # if @model is 'course_tag'
        #     selected_course_tags.push @name
        #     $('.search_subcourse').val('')
        #     Session.set('course_skip_value',0)
    
        'click .unselect_time_tag': ->
            selected_course_time_tags.remove @valueOf()
        'click .select_time_tag': ->
            selected_course_time_tags.push @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            
        'click .unselect_location_tag': ->
            selected_course_location_tags.remove @valueOf()
        'click .select_location_tag': ->
            selected_course_location_tags.push @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
    
        'click .add_post': ->
            new_id = 
                Docs.insert 
                    model:'post'
                    course_id:Router.current().params.doc_id
            Router.go "/course/#{Router.current().params.doc_id}/post/#{new_id}/edit"
            
            
    Template.course_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        # 'click .publish': ->
        #     Docs.update Router.current().params.doc_id,
        #         $set:published:true
        #     if confirm 'confirm?'
        #         Meteor.call 'publish_menu', @_id, =>
        #             Router.go "/menu/#{@_id}/view"


    Template.course_tag_selector.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title_small', @data.name.toLowerCase())
    Template.course_tag_selector.helpers
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
                
    Template.course_tag_selector.events
        'click .select_tag': -> 
            # results.update
            # console.log @
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # if @model is 'course_emotion'
            #     selected_emotions.push @name
            # else
            # if @model is 'course_tag'
            selected_course_tags.push @name
            $('.search_subcourse').val('')
            Session.set('course_skip_value',0)
    
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
            # Session.set('course_loading',true)
            # Meteor.call 'search_course', @name, ->
            #     Session.set('course_loading',false)
            # Meteor.setTimeout( ->
            #     Session.set('toggle',!Session.get('toggle'))
            # , 5000)
            
            
            
    
    Template.course_unselect_tag.onCreated ->
        @autorun => Meteor.subscribe('doc_by_title_small', @data.toLowerCase())
        
    Template.course_unselect_tag.helpers
        term: ->
            found = 
                Docs.findOne 
                    # model:'wikipedia'
                    title:@valueOf().toLowerCase()
            found
    Template.course_unselect_tag.events
        'click .unselect_course_tag': -> 
            Session.set('skip',0)
            # console.log @
            selected_course_tags.remove @valueOf()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
        
    
    Template.flat_course_tag_selector.onCreated ->
        # @autorun => Meteor.subscribe('doc_by_title_small', @data.valueOf().toLowerCase())
    Template.flat_course_tag_selector.helpers
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
    Template.flat_course_tag_selector.events
        'click .select_flat_tag': -> 
            # results.update
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
            selected_course_tags.push @valueOf()
            $('.search_course').val('')




if Meteor.isServer
    Meteor.publish 'course_count', (
        course_id
        selected_tags
        selected_course_time_tags
        selected_course_location_tags
        )->
            
        match = {model:'post', course_id:course_id}
        if selected_tags.length > 0 then match.tags = $all:selected_tags
        if selected_course_time_tags.length > 0 then match.time_tags = $all:selected_course_time_tags
        if selected_course_location_tags.length > 0 then match.location_tags = $all:selected_course_location_tags
        Counts.publish this, 'course_counter', Docs.find(match)
        return undefined
                
    Meteor.publish 'course_posts', (
        course_id
        selected_course_tags
        selected_course_time_tags
        selected_course_location_tags
        sort_key
        sort_direction
        skip=0
        )->
        self = @
        match = {
            model:'post'
            course_id: course_id
        }
        if sort_key
            sk = sort_key
        else
            sk = '_timestamp'
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if selected_course_tags.length > 0 then match.tags = $all:selected_course_tags
        if selected_course_time_tags.length > 0 then match.time_tags = $all:selected_course_time_tags
        if selected_course_location_tags.length > 0 then match.location_tags = $all:selected_course_location_tags
        # if selected_subcourse_domains.length > 0 then match.domain = $all:selected_subcourse_domains
        # if selected_course_authors.length > 0 then match.author = $all:selected_course_authors
        console.log 'skip', skip
        Docs.find match,
            limit:20
            sort: "#{sk}":-1
            skip:skip*20
        
        
    # Meteor.methods    
        # tagify_course: (doc_id)->
        #     doc = Docs.findOne doc_id
        #     # moment(doc.date).fromNow()
        #     # timestamp = Date.now()
    
        #     doc._timestamp_long = moment(doc._timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
        #     # doc._app = 'course'
        
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
        #         # console.log 'course', date_array
        #         Docs.update doc_id, 
        #             $set:addedtime_tags:date_array
        
               
    Meteor.publish 'course_tags', (
        course_id
        selected_course_tags
        selected_course_time_tags
        selected_course_location_tags
        # selected_course_authors
        # view_bounties
        # view_unanswered
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            model:'post'
            course_id:course_id
            # subcourse:subcourse
        }
        # if view_bounties
        #     match.bounty = true
        # if view_unanswered
        #     match.is_answered = false
        if selected_course_tags.length > 0 then match.tags = $all:selected_course_tags
        # if selected_subcourse_domain.length > 0 then match.domain = $all:selected_subcourse_domain
        if selected_course_time_tags.length > 0 then match.time_tags = $all:selected_course_time_tags
        if selected_course_location_tags.length > 0 then match.location_tags = $all:selected_course_location_tags
        # if selected_course_location.length > 0 then match.subcourse = $all:selected_course_location
        # if selected_course_authors.length > 0 then match.author = $all:selected_course_authors
        # if selected_emotion.length > 0 then match.max_emotion_name = selected_emotion
        doc_count = Docs.find(match).count()
        # console.log 'doc_count', doc_count
        course_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_course_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:33 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        course_tag_cloud.forEach (tag, i) ->
            # console.log tag
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'course_tag'
        
        
        # course_domain_cloud = Docs.aggregate [
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
        # course_domain_cloud.forEach (domain, i) ->
        #     self.added 'results', Random.id(),
        #         name: domain.name
        #         count: domain.count
        #         model:'course_domain_tag'
        
        
        course_location_cloud = Docs.aggregate [
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
        course_location_cloud.forEach (location, i) ->
            self.added 'results', Random.id(),
                name: location.name
                count: location.count
                model:'course_location_tag'
        
        
        
        course_time_cloud = Docs.aggregate [
            { $match: match }
            { $project: "time_tags": 1 }
            { $unwind: "$time_tags" }
            { $group: _id: "$time_tags", count: $sum: 1 }
            { $match: _id: $nin: selected_course_time_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:25 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        course_time_cloud.forEach (time_tag, i) ->
            self.added 'results', Random.id(),
                name: time_tag.name
                count: time_tag.count
                model:'course_time_tag'
      
        self.ready()
            