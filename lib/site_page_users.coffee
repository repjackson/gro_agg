if Meteor.isClient
    Router.route '/site/:site', (->
        @layout 'layout'
        @render 'site_questions'
        ), name:'site_questions'
        
    Router.route '/site/:site/doc/:doc_id', (->
        @layout 'layout'
        @render 'stack_page'
        ), name:'stack_page'
    
    Router.route '/site/:site/users', (->
        @layout 'layout'
        @render 'site_users'
        ), name:'site_users'
    

    Template.site_users.onCreated ->
        Session.setDefault('user_query', null)
        Session.setDefault('location_query', null)
        @autorun => Meteor.subscribe 'site_user_count', Router.current().params.site
        @autorun => Meteor.subscribe 'site_by_param', Router.current().params.site
        @autorun => Meteor.subscribe 'stackusers_by_site', 
            Router.current().params.site
            Session.get('user_query')
            Session.get('location_query')
            selected_tags.array()
        @autorun => Meteor.subscribe 'site_user_tags',
            selected_tags.array()
            Router.current().params.site
            Session.get('user_query')
            Session.get('location_query')
            Session.get('toggle')
            Session.get('view_bounties')
            Session.get('view_unanswered')

    Template.site_questions.onCreated ->
        @autorun => Meteor.subscribe 'site_by_param', Router.current().params.site
        @autorun => Meteor.subscribe 'site_tags',
            selected_tags.array()
            Router.current().params.site
            Session.get('toggle')
            Session.get('view_bounties')
            Session.get('view_unanswered')
            
            
        @autorun => Meteor.subscribe 'stack_docs_by_site', 
            Router.current().params.site
            selected_tags.array()
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')
            Session.get('toggle')
            Session.get('view_bounties')
            Session.get('view_unanswered')
            
        @autorun => Meteor.subscribe 'stackusers_by_site', 
            Router.current().params.site
            # selected_tags.array()
            # Session.get('sort_key')
            # Session.get('sort_direction')
            # Session.get('limit')
            # Session.get('toggle')
            
            
    # Template.site_users.onCreated ->
    #     @autorun => Meteor.subscribe 'site_by_param', Router.current().params.site
    #     @autorun => Meteor.subscribe 'site_user_tags',
    #         selected_tags.array()
    #         Router.current().params.site
    #         Session.get('toggle')
            
            
    Template.site_questions.helpers
        selected_tags: -> selected_tags.array()
        site_tags: -> results.find(model:'site_tag')
        current_site: ->
            Docs.findOne
                model:'stack_site'
                api_site_parameter:Router.current().params.site
        site_questions: ->
            Docs.find {
                model:'stack_question'
                site:Router.current().params.site
            },
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
                limit:Session.get('limit')
    
    Template.site_questions.events
        'click .goto_q': -> Router.go "/site/#{@site}/doc/#{@_id}"
        'click .get_info': (e,t)-> 
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            Meteor.call 'get_site_info', Router.current().params.site, ->
        'click .view_question': (e,t)-> window.speechSynthesis.speak new SpeechSynthesisUtterance @title
        'click .sort_timestamp': (e,t)-> Session.set('sort_key','_timestamp')
        'click .unview_bounties': (e,t)-> Session.set('view_bounties',0)
        'click .view_bounties': (e,t)-> Session.set('view_bounties',1)
        'click .unview_unanswered': (e,t)-> Session.set('view_unanswered',0)
        'click .view_unanswered': (e,t)-> Session.set('view_unanswered',1)
        'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
        'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
        'click .sort_up': (e,t)-> Session.set('sort_direction',1)
        'click .limit_10': (e,t)-> Session.set('limit',10)
        'click .limit_1': (e,t)-> Session.set('limit',1)
        'keyup .search_site': (e,t)->
            # search = $('.search_site').val().toLowerCase().trim()
            search = $('.search_site').val().trim()
            if e.which is 13
                if search.length > 0
                    window.speechSynthesis.cancel()
                    # console.log search
                    window.speechSynthesis.speak new SpeechSynthesisUtterance search
                    selected_tags.push search
                    $('.search_site').val('')

                    Meteor.call 'search_stack', Router.current().params.site, search, ->
                        Session.set('thinking',false)
    Template.site_users.events
        'click .set_location': (e,t)->
            Session.set('location_query',@location)
        'keyup .search_location': (e,t)->
            # search = $('.search_site').val().toLowerCase().trim()
            search = $('.search_location').val().trim()
            console.log 'searc', search
            Session.set('location_query',search)
            if e.which is 13
                if search.length > 0
                    window.speechSynthesis.cancel()
                    # console.log search
                    window.speechSynthesis.speak new SpeechSynthesisUtterance search
                    selected_tags.push search
                    $('.search_site').val('')

                    Meteor.call 'search_stack', Router.current().params.site, search, ->
                        Session.set('thinking',false)

        'keyup .search_users': (e,t)->
            # search = $('.search_site').val().toLowerCase().trim()
            user_search = $('.search_users').val().trim()
            Session.set('user_query',user_search)
            if e.which is 13
                if search.length > 0
                    window.speechSynthesis.cancel()
                    # console.log search
                    window.speechSynthesis.speak new SpeechSynthesisUtterance search
                    selected_tags.push user_search
                    $('.search_site').val('')

                    # Meteor.call 'search_stack', Router.current().params.site, search, ->
                        # Session.set('thinking',false)
        'click .get_site_users': ->
            Meteor.call 'get_site_users', Router.current().params.site, ->
        'click .clear_location': (e,t)-> 
            window.speechSynthesis.speak new SpeechSynthesisUtterance "location cleared"
            Session.set('location_query',null)
    
        'click .clear_query': (e,t)-> 
            window.speechSynthesis.speak new SpeechSynthesisUtterance "name cleared"
            Session.set('user_query',null)
        'click .say_name': (e,t)->
            # console.log 'title', @
            window.speechSynthesis.speak new SpeechSynthesisUtterance @display_name

    Template.site_users.helpers
        selected_tags: -> selected_tags.array()
        user_tags: -> results.find(model:'site_user_tag')
        site_locations: -> results.find(model:'site_Location')
        current_location_query: -> Session.get('location_query')
        current_site: ->
            Docs.findOne
                model:'stack_site'
                api_site_parameter:Router.current().params.site
        site_locations: -> results.find(model:'site_Location')
        site_organizations: -> results.find(model:'site_Organization')
        site_persons: -> results.find(model:'site_Person')
        site_companys: -> results.find(model:'site_Company')
        user_count: -> Counts.get('user_counter')

        stackusers: ->
            Docs.find {
                model:'stackuser'
                site:Router.current().params.site
            },
                sort:
                    reputation: -1
                limit:Session.get('limit')
 
 
 
 
    Template.site_questions.helpers
        site_locations: -> results.find(model:'site_Location')
        site_organizations: -> results.find(model:'site_Organization')
        site_persons: -> results.find(model:'site_Person')
        site_companys: -> results.find(model:'site_Company')

        site_users: ->
            Docs.find {
                model:'stackuser'
                site:Router.current().params.site
            },
                sort:
                    reputation: -1
                limit:10
    
    # Template.site_users.events
    #     'click .view_question': (e,t)-> window.speechSynthesis.speak new SpeechSynthesisUtterance @title
    #     'click .sort_timestamp': (e,t)-> Session.set('sort_key','_timestamp')
    #     'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
    #     'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
    #     'click .sort_up': (e,t)-> Session.set('sort_direction',1)
    #     'click .limit_10': (e,t)-> Session.set('limit',10)
    #     'click .limit_1': (e,t)-> Session.set('limit',1)
    #     'keyup .search_site': (e,t)->
    #         # search = $('.search_site').val().toLowerCase().trim()
    #         search = $('.search_site').val().trim()
    #         if e.which is 13
    #             if search.length > 0
    #                 window.speechSynthesis.cancel()
    #                 # console.log search
    #                 window.speechSynthesis.speak new SpeechSynthesisUtterance search
    #                 selected_tags.push search
    #                 $('.search_site').val('')

    #                 Meteor.call 'search_stack', Router.current().params.site, search, ->
    #                     Session.set('thinking',false)

    Template.site_question_item.onCreated ->
        console.log @data.watson
        unless @data.watson
            Meteor.call 'call_watson', @data._id, 'link', 'stack', ->
            
    Template.site_question_item.onRendered ->
        # console.log @
    Template.stack_tag_selector.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
    Template.stack_tag_selector.helpers
        selector_class: ()->
            # console.log @
            term = 
                Docs.findOne 
                    title:@name.toLowerCase()
            if term
                if term.max_emotion_name
                    switch term.max_emotion_name
                        when 'joy' then " basic green #{Meteor.user().invert_class}"
                        when "anger" then " basic red #{Meteor.user().invert_class}"
                        when "sadness" then " basic blue #{Meteor.user().invert_class}"
                        when "disgust" then " basic orange #{Meteor.user().invert_class}"
                        when "fear" then " basic grey #{Meteor.user().invert_class}"
                        else "basic grey #{Meteor.user().invert_class}"
        term: ->
            Docs.findOne 
                title:@name.toLowerCase()
   
   
    Template.stack_tag_selector.events
        'click .select_tag': -> 
            # results.update
            window.speechSynthesis.cancel()
            
            window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            selected_tags.push @name
            $('.search_site').val('')
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
            # Session.set('thinking',true)
            # $('body').toast(
            #     showIcon: 'stack exchange'
            #     message: 'started'
            #     displayTime: 'auto',
            #     position: 'bottom right'
            # )
            Meteor.call 'search_stack', Router.current().params.site, @name, ->
                # $('body').toast(
                #     showIcon: 'stack exchange'
                #     message: ' done'
                #     # showProgress: 'bottom'
                #     class: 'success'
                #     displayTime: 'auto',
                #     position: 'bottom right'
                # )
                # Session.set('thinking',false)
        # Session.set('viewing_doc',null)
            # Meteor.setTimeout( ->
            #     Session.set('toggle',!Session.get('toggle'))
            # , 5000)
       



if Meteor.isServer
    Meteor.publish 'stack_docs_by_site', (
        site
        selected_tags
        sort_key
        sort_direction
        limit
        toggle
        view_bounties
        view_unanswered
    )->
        # console.log 'site', site
        # console.log 'sort_key', sort_key
        # console.log 'sort_direction', sort_direction
        # console.log 'limit', limit
        # site = Docs.findOne
        #     model:'stack_site'
        #     api_site_parameter:site
        match = {
            model:'stack_question'
            site:site
            }
            
        if view_unanswered
            match.is_answered = false
        if view_bounties 
            match.bounty = true
        if selected_tags.length > 0 then match.tags = $all:selected_tags
        if site
            Docs.find match, 
                limit:20
                # sort:
                #     "#{sort_key}":sort_direction
                # limit:limit
    Meteor.publish 'site_tags', (
        selected_tags
        site
        toggle
        view_bounties
        view_unanswered
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            model:'stack_question'
            site:site
            }
        if view_bounties
            match.bounty = true
        if view_unanswered
            match.is_answered = false
        doc_count = Docs.find(match).count()
        # console.log 'tags', selected_tags
        if selected_tags.length > 0 then match.tags = $in:selected_tags
        site_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        # console.log 'cloud: ', tag_cloud
        # console.log 'tag match', match
        site_tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'site_tag'
        
        
        site_Location_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Location": 1 }
            { $unwind: "$Location" }
            { $group: _id: "$Location", count: $sum: 1 }
            # { $match: _id: $nin: selected_Locations }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        # console.log 'cloud: ', Location_cloud
        # console.log 'Location match', match
        site_Location_cloud.forEach (Location, i) ->
            self.added 'results', Random.id(),
                name: Location.name
                count: Location.count
                model:'site_Location'
      
      
        site_Organization_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Organization": 1 }
            { $unwind: "$Organization" }
            { $group: _id: "$Organization", count: $sum: 1 }
            # { $match: _id: $nin: selected_Organizations }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        # console.log 'cloud: ', Organization_cloud
        # console.log 'Organization match', match
        site_Organization_cloud.forEach (Organization, i) ->
            self.added 'results', Random.id(),
                name: Organization.name
                count: Organization.count
                model:'site_Organization'
      
      
        site_Person_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Person": 1 }
            { $unwind: "$Person" }
            { $group: _id: "$Person", count: $sum: 1 }
            # { $match: _id: $nin: selected_Persons }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        # console.log 'cloud: ', Person_cloud
        # console.log 'Person match', match
        site_Person_cloud.forEach (Person, i) ->
            self.added 'results', Random.id(),
                name: Person.name
                count: Person.count
                model:'site_Person'
      
      
        site_Company_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Company": 1 }
            { $unwind: "$Company" }
            { $group: _id: "$Company", count: $sum: 1 }
            # { $match: _id: $nin: selected_Companys }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        # console.log 'cloud: ', Company_cloud
        # console.log 'Company match', match
        site_Company_cloud.forEach (Company, i) ->
            self.added 'results', Random.id(),
                name: Company.name
                count: Company.count
                model:'site_Company'
      
      
        self.ready()
    
    
    
    Meteor.publish 'site_user_tags', (
        selected_tags
        site
        user_query
        location_query
        toggle
        view_bounties
        view_unanswered
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            model:'stackuser'
            site:site
            }
        doc_count = Docs.find(match).count()
        # console.log 'tags', selected_tags
        if selected_tags.length > 0 then match.tags = $in:selected_tags
        site_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        # console.log 'cloud: ', tag_cloud
        # console.log 'tag match', match
        site_tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'site_user_tag'
        
        
        site_Location_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Location": 1 }
            { $unwind: "$Location" }
            { $group: _id: "$Location", count: $sum: 1 }
            # { $match: _id: $nin: selected_Locations }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        # console.log 'cloud: ', Location_cloud
        # console.log 'Location match', match
        site_Location_cloud.forEach (Location, i) ->
            self.added 'results', Random.id(),
                name: Location.name
                count: Location.count
                model:'site_Location'
      
      
        site_Organization_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Organization": 1 }
            { $unwind: "$Organization" }
            { $group: _id: "$Organization", count: $sum: 1 }
            # { $match: _id: $nin: selected_Organizations }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        # console.log 'cloud: ', Organization_cloud
        # console.log 'Organization match', match
        site_Organization_cloud.forEach (Organization, i) ->
            self.added 'results', Random.id(),
                name: Organization.name
                count: Organization.count
                model:'site_Organization'
      
      
        site_Person_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Person": 1 }
            { $unwind: "$Person" }
            { $group: _id: "$Person", count: $sum: 1 }
            # { $match: _id: $nin: selected_Persons }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        # console.log 'cloud: ', Person_cloud
        # console.log 'Person match', match
        site_Person_cloud.forEach (Person, i) ->
            self.added 'results', Random.id(),
                name: Person.name
                count: Person.count
                model:'site_Person'
      
      
        site_Company_cloud = Docs.aggregate [
            { $match: match }
            { $project: "Company": 1 }
            { $unwind: "$Company" }
            { $group: _id: "$Company", count: $sum: 1 }
            # { $match: _id: $nin: selected_Companys }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:7 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        # console.log 'cloud: ', Company_cloud
        # console.log 'Company match', match
        site_Company_cloud.forEach (Company, i) ->
            self.added 'results', Random.id(),
                name: Company.name
                count: Company.count
                model:'site_Company'
      
      
        self.ready()
    
    
    Meteor.publish 'stackusers_by_site', (
        site
        user_query
        location_query
        selected_tags
        sort_key
        sort_direction
        limit
    )->
        console.log 'site', site
        console.log 'sort_key', sort_key
        console.log 'sort_direction', sort_direction
        console.log 'limit', limit
        console.log 'location', location_query
        # site = Docs.findOne
        #     model:'stack_site'
        #     api_site_parameter:site
        match = {
            model:'stackuser'
            site:site
            }
        if user_query
            match.display_name = {$regex:"#{user_query}", $options:'i'}
        if location_query
            match.location = {$regex:"#{location_query}", $options:'i'}
        if selected_tags.length > 0 then match.tags = $all:selected_tags
        if site
            Docs.find match, 
                limit:20
                sort:
                    reputation:-1
                #     "#{sort_key}":sort_direction
                # limit:limit
                