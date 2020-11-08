@selected_tags = new ReactiveArray []
@selected_models = new ReactiveArray []
@selected_subreddits = new ReactiveArray []
@selected_emotions = new ReactiveArray []


Router.route '/dao', (->
    @layout 'layout'
    @render 'dao'
    ), name:'dao'



    
Template.dao.onCreated ->
    @autorun -> Meteor.subscribe('stacks',selected_tags.array())
Template.dao.onCreated ->
    # window.speechSynthesis.cancel()
    
    # window.speechSynthesis.speak new SpeechSynthesisUtterance 'dao'
    # document.title = 'the world'
    Session.setDefault('main_section','alpha')
    Session.setDefault('view_alpha',true)
    Session.setDefault('view_reddit',true)
    Session.setDefault('view_duck',true)
    Session.setDefault('skip',0)
    Session.setDefault('view_section','content')
    @autorun -> Meteor.subscribe('alpha_combo',selected_tags.array())
    # @autorun -> Meteor.subscribe('alpha_single',selected_tags.array())
    @autorun -> Meteor.subscribe('duck',selected_tags.array())
    @autorun -> Meteor.subscribe('search_doc',selected_tags.array())
    @autorun -> Meteor.subscribe('doc_count',
        selected_tags.array()
        Session.get('view_mode')
        Session.get('emotion_mode')
        selected_models.array()
        selected_subreddits.array()
        selected_emotions.array()
        )
    @autorun => Meteor.subscribe('dtags',
        selected_tags.array()
        Session.get('view_mode')
        Session.get('emotion_mode')
        Session.get('toggle')
        selected_models.array()
        selected_subreddits.array()
        selected_emotions.array()
        # Session.get('query')
        )
    @autorun => Meteor.subscribe('docs',
        selected_tags.array()
        Session.get('view_mode')
        Session.get('emotion_mode')
        Session.get('toggle')
        selected_models.array()
        selected_subreddits.array()
        selected_emotions.array()
        # Session.get('query')
        Session.get('skip')
        )



Template.alpha.onRendered ->
    # console.log @data
    # unless @data.watson
    #     # console.log 'call'
    #     Meteor.call 'call_watson', @data._id, 'url','url',->
    # if @data.response
    # window.speechSynthesis.cancel()
    # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.response.queryresult.pods[1].subpods[1].plaintext
    if @data 
        if @data.voice
            window.speechSynthesis.speak new SpeechSynthesisUtterance @data.voice
        else if @data.response.queryresult.pods
            window.speechSynthesis.speak new SpeechSynthesisUtterance @data.response.queryresult.pods[1].subpods[0].plaintext
    # console.log response.queryresult.pods[1].subpods
    # Meteor.setTimeout( =>
    # , 7000)

Template.alpha.helpers
    split_datatypes: ->
        # console.log 'data', @
        split = @datatypes.split ','
        console.log split
        split

Template.alpha.events
    'click .select_datatype': ->
        console.log @
        selected_tags.push @valueOf().toLowerCase()
    'click .alphatemp': ->
        console.log @plaintext
        console.log @plaintext.split '|'
        window.speechSynthesis.cancel()
        window.speechSynthesis.speak new SpeechSynthesisUtterance @plaintext
        




Template.unselect_tag.onCreated ->
    # console.log @
    @autorun => Meteor.subscribe('doc_by_title', @data.toLowerCase())
    
Template.unselect_tag.helpers
    term: ->
        # console.log @valueOf()
        found = 
            Docs.findOne 
                # model:'wikipedia'
                title:@valueOf().toLowerCase()
        #  console.log found
        found
Template.unselect_tag.events
   'click .unselect_tag': -> 
        selected_tags.remove @valueOf()
        Session.set('skip',0)
        # if selected_tags.array().length > 0
        #     if Session.equals('view_mode','porn')
        #         Meteor.call 'search_ph', selected_tags.array(), ->
        #     else if Session.equals('view_mode','stack')
        #         # selected_tags.push @valueOf()
        #         Session.set('thinking',true)
        #         $('body').toast(
        #             showIcon: 'stack exchange'
        #             message: 'started'
        #             displayTime: 'auto',
        #             position: 'bottom right'
        #         )
        #         Meteor.call 'search_stack', @name, ->
        #             $('body').toast(
        #                 showIcon: 'stack exchange'
        #                 message: ' done'
        #                 # showProgress: 'bottom'
        #                 class: 'success'
        #                 displayTime: 'auto',
        #                 position: 'bottom right'
        #             )
        #             Session.set('thinking',false)
        #     else
        #         Session.set('thinking',true)
        #         $('body').toast(
        #             showIcon: 'reddit'
        #             message: 'reddit started'
        #             displayTime: 'auto',
        #         )
        #         Meteor.call 'search_reddit', selected_tags.array(), ->
        #             $('body').toast(
        #                 message: 'reddit done'
        #                 showIcon: 'reddit'
        #                 # showProgress: 'bottom'
        #                 class: 'success'
        #                 displayTime: 'auto',
        #             )
        #             Session.set('thinking',false)
                
        #         Meteor.call 'call_alpha', selected_tags.array().toString(), ->
        #         # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
        #     Meteor.setTimeout( ->
        #         Session.set('toggle',!Session.get('toggle'))
        #     , 12000)

    





Template.tag_selector.onCreated ->
    # console.log @
    @autorun => Meteor.subscribe('doc_by_title', @data.name.toLowerCase())
Template.tag_selector.helpers
    selector_class: ()->
        # console.log @
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
            
Template.dao.events
    'keyup .search_stack': (e,t)->
        # search = $('.search_title').val().toLowerCase().trim()
        search = $('.search_stack').val().trim()
        # _.throttle( =>

        # if search.length > 4
        #     Session.set('query',search)
        # else if search.length is 0
        #     Session.set('query','')
        if e.which is 13
            window.speechSynthesis.cancel()
            # console.log search
            if search.length > 0
                Meteor.call 'search_stack', search, selected_tags.array(), (err,res)->

    # 'click .call_stack': -> Meteor.call 'search_stack', selected_tags.array()
    'click .select_model': -> selected_models.push @name
    'click .select_emotion': -> selected_emotions.push @name
    'click .select_location': -> selected_locations.push @name
    
    'click .unselect_location': -> selected_locations.remove @valueOf()
    'click .unselect_model': -> selected_models.remove @valueOf()
    'click .unselect_subreddit': -> selected_subreddits.remove @valueOf()
    'click .unselect_emotion': -> selected_emotions.remove @valueOf()
            
            
Template.tag_selector.events
    'click .select_tag': -> 
        # results.update
        window.speechSynthesis.cancel()
        
        selected_tags.push @name
        Session.set('query','')
        Session.set('skip',0)
        $('.search_site').val('')
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
        unless Session.equals('view_mode','porn')
            Meteor.call 'call_alpha', selected_tags.array().toString(), ->
        if Session.equals('view_mode','stack')
            Session.set('thinking',true)
            $('body').toast(
                showIcon: 'stack exchange'
                message: 'started'
                displayTime: 'auto',
                position: 'bottom right'
            )
            Meteor.call 'search_stack', Router.current().params.site, @name, ->
                $('body').toast(
                    showIcon: 'stack exchange'
                    message: ' done'
                    # showProgress: 'bottom'
                    class: 'success'
                    displayTime: 'auto',
                    position: 'bottom right'
                )
                Session.set('thinking',false)
        else if Session.equals('view_mode', 'porn')
            Meteor.call 'search_ph', selected_tags.array().toString(), ->
        else
            Session.set('thinking',true)
            $('body').toast(
                showIcon: 'wikipedia'
                message: 'started'
                displayTime: 'auto',
                position: 'bottom right'
            )
            Meteor.call 'call_wiki', @name, ->
                $('body').toast(
                    message: 'done'
                    showIcon: 'wikipedia'
                    # showProgress: 'bottom'
                    class: 'info'
                    displayTime: 'auto',
                    position: 'bottom right'
                )
            $('body').toast(
                showIcon: 'reddit'
                message: 'started'
                displayTime: 'auto',
                position: 'bottom right'    
            )
            Meteor.call 'search_reddit', selected_tags.array(), ->
                $('body').toast(
                    message: 'done'
                    showIcon: 'reddit'
                    # showProgress: 'bottom'
                    class: 'success'
                    displayTime: 'auto',
                    position: 'bottom right'
                )
                Session.set('thinking',false)
        # Meteor.call 'search_ddg', @name, ->
        # Session.set('viewing_doc',null)
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 5000)
       
       
Template.doc_tag.onCreated ->
    # console.log @
    @autorun => Meteor.subscribe('doc_by_title', @data)
Template.doc_tag.helpers
    selector_class: ->
        # console.log @
        term = 
            Docs.findOne 
                title:@valueOf()
        if term
            if term.max_emotion_name
                switch term.max_emotion_name
                    when 'joy' then 'green'
                    when 'anger' then 'red'
                    when 'sadness' then 'blue'
                    when 'disgust' then 'orange'
                    when 'fear' then 'grey'
    term: ->
        Docs.findOne 
            title:@valueOf()
            
            
Template.doc_tag.events
    'click .select_tag': -> 
        # results.update
        window.speechSynthesis.cancel()
        
        selected_tags.push @valueOf()
        Session.set('query','')
        Session.set('skip',0)
        Session.set('viewing_doc',null)
        Session.set('thinking',true)
        $('body').toast(
            showIcon: 'wikipedia'
            message: 'wikipedia started'
            displayTime: 'auto',
        )
        Meteor.call 'call_wiki', @valueOf(), ->
            $('body').toast(
                message: 'done'
                showIcon: 'wikipedia'
                # showProgress: 'bottom'
                class: 'info'
                displayTime: 'auto',
            )
        $('body').toast(
            showIcon: 'reddit'
            message: 'started'
            displayTime: 'auto',
        )
        Meteor.call 'search_reddit', selected_tags.array(), ->
            $('body').toast(
                message: 'done'
                showIcon: 'reddit'
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
            )
            Session.set('thinking',false)
        Meteor.call 'search_ddg', @name, ->
        Meteor.call 'call_alpha', selected_tags.array().toString(), ->
        window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
            
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @valueOf()
        Meteor.setTimeout( ->
            Session.set('toggle',!Session.get('toggle'))
        , 10000)
       
       
       
       
       
# Template.select_subreddit.onCreated ->
#     # console.log @
#     @autorun => Meteor.subscribe('tribe_by_title', @data.name)
# Template.select_subreddit.helpers
#     tribe_doc: ->
#         found = Docs.findOne 
#             title:@name
#             model:'tribe'
#         # console.log found 
#         found 
            
       
       
       

Template.stack_page.events
    'click .add_stack_tag': ->
        selected_tags.push @valueOf()
        # if Session.equals('view_mode','stack')
        Router.go "/site/#{Router.current().params.site}"
        # Session.set('thinking',true)
        # $('body').toast(
        #     showIcon: 'stack exchange'
        #     message: 'started'
        #     displayTime: 'auto',
        #     position: 'bottom right'
        # )
        Meteor.call 'search_stack', Router.current().params.site, @valueOf(), =>
            # $('body').toast(
            #     showIcon: 'stack exchange'
            #     message: ' done'
            #     # showProgress: 'bottom'
            #     class: 'success'
            #     displayTime: 'auto',
            #     position: 'bottom right'
            # )
            # Session.set('thinking',false)
    # 'click .toggle_alpha': -> 
    #     console.log Session.get 'view_alpha'
    #     Session.set('view_alpha', !Session.get('view_alpha'))
    # 'click .toggle_reddit': -> 
    #     console.log Session.get 'view_reddit'
    #     Session.set('view_reddit', !Session.get('view_reddit'))
    # 'click .toggle_duck': -> 
    #     console.log Session.get 'view_duck'
    #     Session.set('view_duck', !Session.get('view_duck'))
Template.alpha.helpers
    alphas: ->
        Docs.find 
            model:'alpha'
            # query: $in: selected_tags.array()
            query: selected_tags.array().toString()
Template.dao.helpers
    search_icon_class: ->
        res = ''
        # 'brown poop loading'
        if Session.get('thinking')
            res += ' loading'
            
        if Session.equals('view_mode','reddit')
            res += ' reddit'
        else if Session.equals('view_mode','stack')
            res += ' stack exchange'
        else if Session.equals('view_mode','wikipedia')
            res += ' wikipedia'
        else if Session.equals('view_mode','porn')
            res += ' mercury'
        # console.log 'res', res
        res
    # viewing_duck: -> Session.get('view_duck')
    # viewing_alpha: -> Session.get('view_alpha')
    # viewing_reddit: -> Session.get('view_reddit')
    search_doc: ->
        Docs.findOne 
            model:'search'
            tags:$in:selected_tags.array()

    viewing_doc: -> Session.get('viewing_doc')
    alphas: ->
        Docs.find 
            model:'alpha'
            # query: $in: selected_tags.array()
            query: selected_tags.array().toString()
    # alpha_singles: ->
    #     Docs.find 
    #         model:'alpha'
    #         query: $in: selected_tags.array()
    #         # query: selected_tags.array().toString()
    ducks: ->
        Docs.find 
            model:'duck'
            # query: $in: selected_tags.array()
            query: selected_tags.array().toString()
    many_tags: -> selected_tags.array().length > 1
    doc_count: -> Counts.get('result_counter')
    stack_docs: ->
        if Session.get('viewing_doc')
            Docs.find Session.get('viewing_doc')
        else
            match = {model:'stack'}
            if selected_tags.array().length>0
                match.tags = $all:selected_tags.array()
            Docs.find match,
                sort:
                    _timestamp:-1
                    points:-1
                    ups:-1
                    # "#{Session.get('sort_key')}": Session.get('sort_direction')
                limit:10
                # skip:Session.get('skip')
    wiki_docs: ->
        if Session.get('viewing_doc')
            Docs.find Session.get('viewing_doc')
        else
            match = {model:'wikipedia'}
            if selected_tags.array().length>0
                match.tags = $all:selected_tags.array()
         
            Docs.find match,
                sort:
                    points:-1
                    ups:-1
                    # _timestamp:-1
                    # "#{Session.get('sort_key')}": Session.get('sort_direction')
                limit:10
                # skip:Session.get('skip')
    reddit_docs: ->
        if Session.get('viewing_doc')
            Docs.find Session.get('viewing_doc')
        else
            match = {model:'reddit'}
            if selected_tags.array().length>0
                match.tags = $all:selected_tags.array()
            Docs.find match,
                sort:
                    points:-1
                    ups:-1
                    # _timestamp:-1
                    # "#{Session.get('sort_key')}": Session.get('sort_direction')
                limit:10
                # skip:Session.get('skip')
            # if cur.count() is 1
            # Docs.find match
    ph_docs: ->
        match = {model:'porn'}
        if selected_tags.array().length>0
            match.tags = $all:selected_tags.array()
        Docs.find match,
            sort:
                points:-1
                views:-1
                # _timestamp:-1
                # "#{Session.get('sort_key')}": Session.get('sort_direction')
            limit:10
            # skip:Session.get('skip')
        # if cur.count() is 1
        # Docs.find match

    loading_class: ->
        if Template.instance().subscriptionsReady()
            console.log 'ready'
            ''
        else
            console.log 'NOT READY'
            'disabled loading'

    # term: ->
    #     # console.log @
    #     Docs.find 
    #         model:'wikipedia'
    #         title:@valueOf()
    
    selected_tags: -> selected_tags.array()
    selected_models: -> selected_models.array()
    selected_subreddits: -> selected_subreddits.array()
    selected_emotions: -> selected_emotions.array()
   
    site_results: -> results.find(model:'site')
    sport_results: -> results.find(model:'sport')
    award_results: -> results.find(model:'award')
    movie_results: -> results.find(model:'movie')
    company_results: -> results.find(model:'company')
    print_results: -> results.find(model:'print')
    # domain_results: -> results.find(model:'domain')
    tvshow_results: -> results.find(model:'tvshow')
    emotion_results: -> results.find(model:'emotion')
    model_results: -> results.find(model:'model')
    location_results: -> results.find(model:'location')
    person_results: -> results.find(model:'person')
    subreddit_results: -> results.find(model:'subreddit')
    tag_results: ->
        # match = {model:'wikipedia'}
        # doc_count = Docs.find(match).count()
        # if 0 < doc_count < 3 
        #     results.find({ 
        #         count:$lt:doc_count 
        #         model:'tag'
        #     })
        # else 
        results.find(model:'tag')
   
Template.dao.events   
    'click .add_tag': -> 
        console.log @
        selected_tags.push @name
        # # if Meteor.user()
        Session.set('thinking',true)
        Session.set('viewing_doc',null)
        $('body').toast(
            showIcon: 'search'
            message: "reddit: #{selected_tags.array()} search started"
            displayTime: 'auto',
            position: 'bottom right'
        )
        Meteor.call 'search_reddit', selected_tags.array(), ->
            $('body').toast(
                showIcon: 'search'
                message: 'reddit done'
                showIcon: 'brain'
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: 'bottom right'
            )
        $('body').toast(
            showIcon: 'search'
            message: "wiki: #{@name} search started"
            displayTime: 'auto',
            position: 'bottom right'
        )
        Meteor.call 'call_wiki', @name, ->
            $('body').toast(
                showIcon: 'search'
                message: 'wikipedia search done'
                showIcon: 'brain'
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: 'bottom right'
            )
            Session.set('thinking',false)
        # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()

        window.speechSynthesis.speak new SpeechSynthesisUtterance @name


Template.duck.events
    'click .topic': (e,t)-> 
        console.log @
        window.speechSynthesis.speak new SpeechSynthesisUtterance @Text
        # console.log @FirstURL.replace(/\s+/g, '-')
        url = new URL(@FirstURL);
        console.log url
        console.log url.pathname
        selected_tags.push @Text.toLowerCase()
        Meteor.call 'call_wiki', selected_tags.array().toString(), ->
        Meteor.call 'search_reddit', selected_tags.array(), ->

    'click .abstract': (e,t)-> 
        console.log @
        window.speechSynthesis.speak new SpeechSynthesisUtterance @AbstractText

    # 'click .tagger': (e,t)->
    #     Meteor.call 'call_watson', @_id, 'url', 'url', ->


            

Template.dao.events
    'click #clear_tags': -> 
        selected_tags.clear()
        window.speechSynthesis.cancel()


    'click .search_title': (e,t)->
        Session.set('toggle',!Session.get('toggle'))
        # window.speechSynthesis.cancel()# 
        # window.speechSynthesis.speak new SpeechSynthesisUtterance 'hail satan'

    # 'keyup .search_title': _.throttle((e,t)->
    'keyup .search_title': (e,t)->
        # search = $('.search_title').val().toLowerCase().trim()
        search = $('.search_title').val().trim()
        # _.throttle( =>

        # if search.length > 4
        #     Session.set('query',search)
        # else if search.length is 0
        #     Session.set('query','')
        if e.which is 13
            window.speechSynthesis.cancel()
            # console.log search
            if search.length > 0
                # Meteor.call 'check_url', search, (err,res)->
                #     console.log res
                #     if res
                #         alert 'url'
                #         Meteor.call 'lookup_url', search, (err,res)=>
                #             console.log res
                #             for tag in res.tags
                #                 selected_tags.push tag
                #             Session.set('skip',0)
                #             Session.set('query','')
                #             $('.search_title').val('')
                #     else
                # unless search in selected_tags.array()
                selected_tags.push search
                # console.log 'selected tags', selected_tags.array()
                # Meteor.call 'call_alpha', search, ->
                if Session.equals('view_mode','porn')
                    Meteor.call 'search_ph', search, ->
                else if Session.equals('view_mode','stack')
                    Session.set('thinking',true)
                    $('body').toast(
                        showIcon: 'stack exchange'
                        message: 'started'
                        displayTime: 'auto',
                        position: 'bottom right'
                    )
                    Meteor.call 'search_stack', search, ->
                        $('body').toast(
                            showIcon: 'stack exchange'
                            message: ' done'
                            # showProgress: 'bottom'
                            class: 'success'
                            displayTime: 'auto',
                            position: 'bottom right'
                        )
                        Session.set('thinking',false)
                else
                    # window.speechSynthesis.speak new SpeechSynthesisUtterance search
                    Session.set('thinking',true)
                    $('body').toast(
                        showIcon: 'search'
                        message: 'started'
                        displayTime: 'auto',
                        position: 'bottom right'
                    )
                    Meteor.call 'search_ddg', search, ->
                        $('body').toast(
                            showIcon: 'search'
                            message: ' done'
                            # showProgress: 'bottom'
                            class: 'success'
                            displayTime: 'auto',
                            position: 'bottom right'
                        )
                    window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()
                    $('body').toast(
                        showIcon: 'brain'
                        message: 'start'
                        displayTime: 'auto',
                        position: 'bottom right'
                    )
                    Session.set('loading_alpha', true)
                    Meteor.call 'call_alpha', selected_tags.array().toString(), ->
                        $('body').toast(
                            message: 'done'
                            showIcon: 'brain'
                            # showProgress: 'bottom'
                            class: 'success'
                            displayTime: 'auto',
                            position: 'bottom right'
                        )
                        Session.set('loading_alpha', false)
                    $('body').toast(
                        showIcon: 'wikipedia'
                        message: 'started'
                        displayTime: 'auto',
                        position: 'bottom right'
                    )
                    Meteor.call 'call_wiki', search, ->
                        $('body').toast(
                            message: 'done'
                            showIcon: 'wikipedia'
                            # showProgress: 'bottom'
                            class: 'info'
                            displayTime: 'auto',
                            position: 'bottom right'
                        )
                    $('body').toast(
                        showIcon: 'reddit'
                        message: ' started'
                        displayTime: 'auto',
                        position: 'bottom right'
                    )
                    Meteor.call 'search_reddit', selected_tags.array(), ->
                        $('body').toast(
                            message: ' done'
                            showIcon: 'reddit'
                            # showProgress: 'bottom'
                            class: 'success'
                            displayTime: 'auto',
                            position: 'bottom right'
                        )
                        Session.set('thinking',false)
                    Session.set('viewing_doc',null)

                Session.set('skip',0)
                # window.speechSynthesis.speak new SpeechSynthesisUtterance selected_tags.array().toString()

                # Session.set('query','')
                $('.search_title').val('')
                Meteor.setTimeout( ->
                    Session.set('toggle',!Session.get('toggle'))
                , 12000)
        # if e.which is 8
        #     if search.length is 0
        #         selected_tags.pop()
    # , 1000)


Template.view_mode.helpers
    toggle_view_class: -> if Session.equals('view_mode',@k) then "#{@i} big #{@c}" else "#{@i} large"
    toggle_view_button_class: -> if Session.equals('view_mode',@k) then "big active" else "basic"

Template.view_mode.events
    'click .toggle_view': -> 
        if Session.equals('view_mode', @k)
            Session.set('view_mode', null)
        else
            Session.set('view_mode', @k)
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @k


Template.emotion_mode.helpers
    toggle_emotion_class: -> 
        if Session.equals('emotion_mode',@k) then "#{@i2} big #{@c} basic" else "#{@i2} large basic"
    selected_emotion: ->  Session.equals('emotion_mode',@k)

Template.emotion_mode.events
    'click .toggle_emotion': -> 
        if Session.equals('emotion_mode', @k)
            Session.set('emotion_mode', null)
        else
            Session.set('emotion_mode', @k)
            # window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @k



Template.pull_reddit.events
    'click .pull': -> 
        Meteor.call 'get_reddit_post', @_id, @reddit_id, ->
        # Meteor.call 'search_stack', selected_tags.array(), ->
Template.call_watson.events
    'click .pull': -> 
        Meteor.call 'call_watson', @_id, 'url','url', ->
        # Meteor.call 'search_stack', selected_tags.array(), ->
       
