Router.route '/', (->
    @layout 'layout'
    @render 'subs'
    ), name:'home'


    
Template.registerHelper 'skv_is', (key, value) ->
    Session.equals key,value

Template.tag_picker.onCreated ->
    if @data.name
        @autorun => Meteor.subscribe('doc_by_title_small', @data.name.toLowerCase())
Template.tag_picker.helpers
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

Template.skve.events
    'click .set_session_v': ->
        # if Session.equals(@k,@v)
        #     Session.set(@k, null)
        # else
        Session.set(@k, @v)

Template.skve.helpers
    calculated_class: ->
        res = ''
        if @classes
            res += @classes
        if Session.get(@k)
            if Session.equals(@k,@v)
                res += ' large compact black'
            else
                # res += ' compact displaynone'
                res += ' compact basic '
            res
        else
            'basic '
    selected: -> Session.equals(@k,@v)
        