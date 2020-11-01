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
        @autorun => Meteor.subscribe 'stack_docs_by_site', Router.current().params.site
    Template.site_page.helpers
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
        'click .sort_timestamp': (e,t)-> Session.set('sort_key','_timestamp')
        'click .sort_down': (e,t)-> Session.set('sort_direction',-1)
        'click .sort_up': (e,t)-> Session.set('sort_direction',1)
        'click .limit_10': (e,t)-> Session.set('limit',10)
        'click .limit_1': (e,t)-> Session.set('limit',1)
        'keyup .search_site': (e,t)->
            # search = $('.search_site').val().toLowerCase().trim()
            search = $('.search_site').val().trim()
            if e.which is 13
                # window.speechSynthesis.cancel()
                # console.log search
                if search.length > 0
                    site = 
                        Docs.findOne
                            model:'stack_site'
                            api_site_parameter:Router.current().params.site
                    if site
                        Meteor.call 'search_stack', site.api_site_parameter, search, ->

