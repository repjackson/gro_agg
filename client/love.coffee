# @selected_sub_tags = new ReactiveArray []
# @selected_subreddit_domain = new ReactiveArray []
# @selected_subreddit_time_tags = new ReactiveArray []
# @selected_subreddit_authors = new ReactiveArray []


Template.love.onCreated ->
    # Session.setDefault('subreddit_view_layout', 'grid')
    Session.setDefault('sort_key', 'data.created')
    Session.setDefault('sort_direction', -1)
    # Session.setDefault('location_query', null)
    @autorun => Meteor.subscribe 'love',
    @autorun => Meteor.subscribe 'group_tags',
        Router.current().params.group
        selected_tags.array()
        selected_time_tags.array()
        selected_location_tags.array()
        # selected_group_authors.array()
        Session.get('toggle')
    @autorun => Meteor.subscribe 'group_count', 
        Router.current().params.group
        selected_tags.array()
        selected_time_tags.array()
        selected_location_tags.array()
    
    @autorun => Meteor.subscribe 'group_posts', 
        Router.current().params.group
        selected_tags.array()
        selected_time_tags.array()
        selected_location_tags.array()
        Session.get('group_sort_key')
        Session.get('group_sort_direction')
        Session.get('group_skip_value')



@selected_love_tags = new ReactiveArray []
@selected_love_time_tags = new ReactiveArray []
@selected_love_location_tags = new ReactiveArray []


Template.love.helpers
    expressions: ->
        Docs.find
            model:'love'
        
        
Template.love.events
    'click .upvote': ->
        Docs.update @_id,
            $inc:points:1
    'click .downvote': ->
        Docs.update @_id,
            $inc:points:-1
    'keyup .add_tag': (e,t)->
        if e.which is 13
            new_tag = $(e.currentTarget).closest('.add_tag').val().toLowerCase().trim()
            Docs.update @_id,
                $addToSet: tags:new_tag
            $(e.currentTarget).closest('.add_tag').val('')
    'click .submit': ->
        l = $('.add_l').val().toLowerCase().trim()
        o = $('.add_o').val().toLowerCase().trim()
        v = $('.add_v').val().toLowerCase().trim()
        e = $('.add_e').val().toLowerCase().trim()
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