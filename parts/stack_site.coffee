if Meteor.isClient
    Router.route '/site/:site', (->
        @layout 'layout'
        @render 'site_page'
        ), name:'site_page'
    
    Router.route '/site/:site/doc/:doc_id', (->
        @layout 'layout'
        @render 'stack_page'
        ), name:'stack_page'
    
    Template.site_page.onCreated ->
        @autorun => Meteor.subscribe 'site_by_param', Router.current().params.site
        @autorun => Meteor.subscribe 'site_tags',
            selected_tags.array()
            Router.current().params.site
            Session.get('toggle')
            
        @autorun => Meteor.subscribe 'stack_docs_by_site', 
            Router.current().params.site
            selected_tags.array()
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')
            Session.get('toggle')
            
            
    Template.site_page.helpers
        selected_tags: -> selected_tags.array()
        site_tags: -> results.find(model:'site_tag')
        current_site: ->
            Docs.findOne
                model:'stack_site'
                api_site_parameter:Router.current().params.site
        site_questions: ->
            Docs.find {
                model:'stack'
                site:Router.current().params.site
            },
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
                limit:Session.get('limit')
    
    Template.site_page.events
        'click .view_question': (e,t)-> window.speechSynthesis.speak new SpeechSynthesisUtterance @title
        'click .sort_timestamp': (e,t)-> Session.set('sort_key','_timestamp')
        'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
        'click .toggle_detail': (e,t)-> 
            Session.set('view_detail',!Session.get('view_detail'))
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
            
            selected_tags.push @name
            $('.search_site').val('')
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
            window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
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
    )->
        console.log 'site', site
        console.log 'sort_key', sort_key
        console.log 'sort_direction', sort_direction
        console.log 'limit', limit
        # site = Docs.findOne
        #     model:'stack_site'
        #     api_site_parameter:site
        match = {
            model:'stack'
            site:site
            }
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
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            model:'stack'
            site:site
            }
        # console.log 'tags', selected_tags
        if selected_tags.length > 0 then match.tags = $in:selected_tags
        site_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            # { $match: count: $lt: doc_count }
            { $limit:20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        # console.log 'cloud: ', tag_cloud
        console.log 'tag match', match
        site_tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'site_tag'
        self.ready()
