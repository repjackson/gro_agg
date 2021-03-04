Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'subs'
    loadingTemplate: 'splash'
    trackPageView: false
# 	progressTick: false
# 	progressDelay: 100
# Router.route '*', -> @render 'not_found'





Template.registerHelper 'skv_is', (key, value) ->
    Session.equals key,value



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
        
        
