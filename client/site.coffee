Router.route '/s/:site', (->
    @layout 'layout'
    @render 'sq'
    ), name:'sq'
    
Router.route '/s/:site/users', (->
    @layout 'layout'
    @render 'su'
    ), name:'su'


Template.su.onCreated ->
    Session.setDefault('user_query', null)
    Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'site_user_count', Router.current().params.site
    @autorun => Meteor.subscribe 'site_by_param', Router.current().params.site
    @autorun => Meteor.subscribe 'stackusers_by_site', 
        Router.current().params.site
        Session.get('user_query')
        Session.get('location_query')
        selected_tags.array()
        ()->Session.set('ready',true)
    @autorun => Meteor.subscribe 'site_user_tags',
        selected_tags.array()
        Router.current().params.site
        Session.get('user_query')
        Session.get('location_query')
        Session.get('toggle')
        Session.get('view_bounties')
        Session.get('view_unanswered')
        ()->Session.set('ready',true)

Template.sq.onCreated ->
    Session.setDefault('sort_direction', -1)
    @autorun => Meteor.subscribe 'agg_sentiment_site',
        Router.current().params.site
        selected_tags.array()
        ()->Session.set('ready',true)

    @autorun => Meteor.subscribe 'site_q_count', 
        Router.current().params.site
        selected_tags.array()
    @autorun => Meteor.subscribe 'sentiment',
        Router.current().params.site
        selected_tags.array()
    @autorun => Meteor.subscribe 'site_by_param', Router.current().params.site
    @autorun => Meteor.subscribe 'site_tags',
        selected_tags.array()
        selected_emotions.array()
        Router.current().params.site
        Session.get('toggle')
        Session.get('view_bounties')
        Session.get('view_unanswered')
        
        
    @autorun => Meteor.subscribe 'stack_docs_by_site', 
        Router.current().params.site
        selected_tags.array()
        selected_emotions.array()
        Session.get('sort_key')
        Session.get('sort_direction')
        Session.get('limit')
        Session.get('toggle')
        Session.get('view_bounties')
        Session.get('view_unanswered')
        
    @autorun => Meteor.subscribe 'stackusers_by_site', 
        Router.current().params.site
        Session.get('user_query')
        Session.get('location_query')
        selected_tags.array()
        ()->Session.set('ready',true)
        
        
# Template.su.onCreated ->
#     @autorun => Meteor.subscribe 'site_by_param', Router.current().params.site
#     @autorun => Meteor.subscribe 'site_user_tags',
#         selected_tags.array()
#         Router.current().params.site
#         Session.get('toggle')
        
        
Template.sq.helpers
    emotion_avg: -> results.findOne(model:'emotion_avg')

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
    q_count: -> Counts.get('site_q_counter')

Template.sq.events
    'click .goto_q': -> Router.go "/s/#{@site}/q/#{@question_id}"
    'click .get_info': (e,t)-> 
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        Meteor.call 'get_site_info', Router.current().params.site, ->
    'click .view_question': (e,t)-> 
        window.speechSynthesis.speak new SpeechSynthesisUtterance @title
        Router.go "/s/#{Router.current().params.site}/q/#{@question_id}"
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
                window.speechSynthesis.speak new SpeechSynthesisUtterance search
                selected_tags.push search
                $('.search_site').val('')

                Meteor.call 'search_stack', Router.current().params.site, search, ->
                    Session.set('thinking',false)
Template.su.events
    'click .set_location': (e,t)->
        window.speechSynthesis.speak new SpeechSynthesisUtterance "#{Router.current().params.site} users in #{@location}"
        Session.set('location_query',@location)
        Session.set('ready',false)
    'keyup .search_location': (e,t)->
        # search = $('.search_site').val().toLowerCase().trim()
        search = $('.search_location').val().trim()
        Session.set('location_query',search)
        Session.set('ready',false)
        if e.which is 13
            if search.length > 0
                window.speechSynthesis.cancel()
                window.speechSynthesis.speak new SpeechSynthesisUtterance search
                selected_tags.push search
                $('.search_site').val('')

                Meteor.call 'search_stack', Router.current().params.site, search, ->
                    Session.set('thinking',false)

    'keyup .search_users': (e,t)->
        # search = $('.search_site').val().toLowerCase().trim()
        user_search = $('.search_users').val().trim()
        Session.set('user_query',user_search)
        Session.set('ready',false)
        if e.which is 13
            if search.length > 0
                window.speechSynthesis.cancel()
                window.speechSynthesis.speak new SpeechSynthesisUtterance search
                selected_tags.push user_search
                $('.search_site').val('')

                # Meteor.call 'search_stack', Router.current().params.site, search, ->
                    # Session.set('thinking',false)
    'click .get_site_users': ->
        Meteor.call 'get_site_users', Router.current().params.site, ->
    'click .clear_location': (e,t)-> 
        window.speechSynthesis.speak new SpeechSynthesisUtterance "location cleared"
        Session.set('ready',false)
        Session.set('location_query',null)


    'click .clear_query': (e,t)-> 
        window.speechSynthesis.speak new SpeechSynthesisUtterance "name cleared"
        Session.set('user_query',null)
    'click .say': (e,t)->
        window.speechSynthesis.speak new SpeechSynthesisUtterance @display_name

Template.su.helpers
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


Template.stackuser_item.onRendered ->
    unless @data.site_rank
        Meteor.call 'rank_user', Router.current().params.site, @data.user_id, ->
        Meteor.call 'search_stackuser', Router.current().params.site, @data.user_id, ->


Template.sq.helpers
    site_locations: -> results.find(model:'site_Location')
    site_organizations: -> results.find(model:'site_Organization')
    site_persons: -> results.find(model:'site_Person')
    site_companys: -> results.find(model:'site_Company')
    site_emotions: -> results.find(model:'site_emotion')

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
#                 window.speechSynthesis.speak new SpeechSynthesisUtterance search
#                 selected_tags.push search
#                 $('.search_site').val('')

#                 Meteor.call 'search_stack', Router.current().params.site, search, ->
#                     Session.set('thinking',false)

Template.s_q_item.onCreated ->
    unless @data.watson
        Meteor.call 'call_watson', @data._id, 'link', 'stack', ->
Template.s_q_item.onRendered ->


Template.stack_tag_selector.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title_small', @data.name.toLowerCase())
Template.stack_tag_selector.helpers
    selector_class: ()->
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
        # console.log @
        window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        if @model is 'site_emotion'
            selected_emotions.push @name
        else
            # if @model is 'site_tag'
            selected_tags.push @name
            $('.search_site').val('')
            
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
        Session.set('loading',true)
        Meteor.call 'search_stack', Router.current().params.site, @name, ->
            Session.set('loading',false)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 5000)
   

Template.flat_tag_selector.onCreated ->
    @autorun => Meteor.subscribe('doc_by_title_small', @data.valueOf().toLowerCase())
Template.flat_tag_selector.helpers
    selector_class: ()->
        term = 
            Docs.findOne 
                title:@valueOf().toLowerCase()
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
            title:@valueOf().toLowerCase()
Template.flat_tag_selector.events
    'click .select_flat_tag': -> 
        # results.update
        window.speechSynthesis.cancel()
        window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        selected_tags.push @valueOf()
        Router.go "/s/#{Router.current().params.site}/"
        $('.search_site').val('')
        Meteor.call 'search_stack', Router.current().params.site, @valueOf(), ->
   
