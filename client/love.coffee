# @selected_sub_tags = new ReactiveArray []
# @selected_subreddit_domain = new ReactiveArray []
# @selected_subreddit_time_tags = new ReactiveArray []
# @selected_subreddit_authors = new ReactiveArray []


Template.love.onCreated ->
    Session.setDefault('subreddit_view_layout', 'grid')
    Session.setDefault('sort_key', 'data.created')
    Session.setDefault('sort_direction', -1)
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'love',
#     @autorun => Meteor.subscribe 'sub_docs_by_name', 
#         Router.current().params.subreddit
#         selected_s


Template.love.helpers
    expressions: ->
        Docs.find
            model:'love'
        
        
Template.love.events
    'click .submit': ->
        l = $('.add_l').val()
        o = $('.add_o').val()
        v = $('.add_v').val()
        e = $('.add_e').val()
        console.log l,o,v,e
        if confirm 'submit expression?'
            $('.add_l').val('')
            $('.add_o').val('')
            $('.add_v').val('')
            $('.add_e').val('')
            
            Docs.insert 
                model:'love'
                l_value:l
                o_value:o
                v_value:v
                e_value:e