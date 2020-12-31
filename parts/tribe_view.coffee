if Meteor.isClient
    Template.tribe_posts.onRendered ->
        Session.setDefault('tribe_view_layout', 'list')

    Template.tribe_selector.onCreated ->
        # console.log @
        if @data.name
            @autorun => Meteor.subscribe('doc_by_title_small', @data.name.toLowerCase())
    
    Template.tribe_selector.helpers
        selector_class: ()->
            term = 
                Docs.findOne 
                    title:@name.toLowerCase()
            if term
                if term.max_emotion_name
                    switch term.max_emotion_name
                        when 'joy' then ' basic green'
                        when 'anger' then ' basic red'
                        when 'sadness' then ' basic blue'
                        when 'disgust' then ' basic orange'
                        when 'fear' then ' basic grey'
                        else 'basic'
        term: ->
            Docs.findOne 
                title:@name.toLowerCase()


    Template.tribe_posts.events
        'click .create_post': ->
            new_id = Docs.insert
                model:'post'
                tribe:Router.current().params.name
            Router.go "/p/#{new_id}/edit"
        'click .sort_timestamp': (e,t)-> Session.set('tribe_sort_key','_timestamp')
        'click .unview_bounties': (e,t)-> Session.set('view_bounties',0)
        'click .view_bounties': (e,t)-> Session.set('view_bounties',1)
        'click .unview_unanswered': (e,t)-> Session.set('view_unanswered',0)
        'click .view_unanswered': (e,t)-> Session.set('view_unanswered',1)
        'click .sort_down': (e,t)-> Session.set('tribe_sort_direction',-1)
        'click .sort_up': (e,t)-> Session.set('tribe_sort_direction',1)
        'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
        'click .limit_10': (e,t)-> Session.set('tribe_limit',10)
        'click .limit_1': (e,t)-> Session.set('tribe_limit',1)
        'click .set_grid': (e,t)-> Session.set('tribe_view_layout', 'grid')
        'click .set_list': (e,t)-> Session.set('tribe_view_layout', 'list')
        'keyup .search_site': (e,t)->
            # search = $('.search_site').val().toLowerCase().trim()
            search = $('.search_site').val().trim()
            if e.which is 13
                if search.length > 0
                    window.speechSynthesis.cancel()
                    window.speechSynthesis.speak new SpeechSynthesisUtterance search
                    selected_tags.push search
                    $('.search_site').val('')
    
                    Session.set('loading',true)
                    Meteor.call 'search_stack', Router.current().params.site, search, ->
                        Session.set('loading',false)

    Template.tribe_posts.helpers
        grid_class: -> if Session.equals('tribe_view_layout', 'grid') then 'black' else 'basic'
        list_class: -> if Session.equals('tribe_view_layout', 'list') then 'black' else 'basic'
    Template.tribe_view.onRendered ->
        @autorun => Meteor.subscribe 'tribe_members', Router.current().params.name
    Template.tribe_view.events
        'click .create_tribe': ->
            # console.log 'creating'
            Docs.insert 
                model:'tribe'
                name:Router.current().params.name
    Template.tribe_edit.helpers
        enabled_features: ->
            tribe = Docs.findOne Router.current().params.doc_id
            Docs.find 
                model:'feature'
                _id:$in:tribe.enabled_feature_ids
        disabled_features: ->
            tribe = Docs.findOne Router.current().params.doc_id
            if tribe.enabled_feature_ids
                Docs.find 
                    model:'feature'
                    _id:$nin:tribe.enabled_feature_ids
            else
                Docs.find 
                    model:'feature'
