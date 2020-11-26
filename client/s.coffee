@selected_stack_tags = new ReactiveArray []
@selected_site_tags = new ReactiveArray []

Router.route '/stack', (->
    @layout 'layout'
    @render 'stack'
    ), name:'stack'




# Template.body.events
#     'click .say_site': -> 
#         window.speechSynthesis.speak new SpeechSynthesisUtterance @site

Template.stack.events
    'click .goto_site': -> 
        Router.go "/s/#{@api_site_parameter}"
        window.speechSynthesis.speak new SpeechSynthesisUtterance "#{@name} #{@audience}"
        selected_tags.clear()
    # 'click .site': -> 
    #     window.speechSynthesis.speak new SpeechSynthesisUtterance @name




        
            
Template.stack.onCreated ->
    # @autorun => Meteor.subscribe 'stack_docs',
    #     selected_stack_tags.array()
    @autorun -> Meteor.subscribe 'stack_sites_small',
        selected_tags.array()
        Session.get('site_name_filter')
Template.stack.helpers
    site_docs: ->
        Docs.find {model:'stack_site'},
            {
                limit:20
                sort:
                    "#{Session.get('sort_key')}": parseInt(Session.get('sort_direction'))
            }
    stack_docs: ->
        Docs.find
            model:'stack_question'

Template.stack.events
    'click .doc': ->
    'click .dl': ->
        Meteor.call 'stack_sites'
    'keyup .search_site_name': ->
        search = $('.search_site_name').val()
        Session.set('site_name_filter', search)
        