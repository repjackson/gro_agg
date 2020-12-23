@selected_ruser_tags = new ReactiveArray []
# @selected_user_roles = new ReactiveArray []


Router.route '/rusers', (->
    @render 'rusers'
    ), name:'rusers'

# Template.term_image.onCreated ->
Template.rusers.onCreated ->
    Session.setDefault('selected_user_location',null)
    Session.setDefault('searching_location',null)
    @autorun -> Meteor.subscribe 'selected_rusers', 
        selected_ruser_tags.array() 
        Session.get('searching_username')
        Session.get('limit')
    @autorun -> Meteor.subscribe('ruser_tags',
        selected_ruser_tags.array()
        Session.get('username_query')
        # selected_user_roles.array()
        # Session.get('view_mode')
    )

Template.rusers.events
    'click .select_user': ->
        window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @display_name
    'keyup .search_username': (e,t)->
        val = $('.search_username').val()
        Session.set('searching_username',val)


Template.rusers.helpers
    current_username_query: -> Session.get('searching_username')
    users: ->
        match = {model:'ruser'}
        # unless 'admin' in Meteor.user().roles
        #     match.site = $in:['member']
        if selected_ruser_tags.array().length > 0 then match.tags = $all: selected_ruser_tags.array()
        Docs.find match,
            sort:points:-1
        # if Meteor.user()
        #     if 'admin' in Meteor.user().roles
        #         Meteor.users.find()
        #     else
        #         Meteor.users.find(
        #             # site:$in:['l1']
        #             site:$in:['member']
        #         )
        # else
        #     Meteor.users.find(
        #         site:$in:['member']
        #     )

# Template.member_card.helpers
#     credit_ratio: ->
#         unless @debit_count is 0
#             @debit_count/@debit_count

# Template.member_card.events
#     'click .calc_points': ->
#         Meteor.call 'calc_user_points', @_id, ->
#     'click .debit': ->
#         # user = Meteor.users.findOne(username:@username)
#         new_debit_id =
#             Docs.insert
#                 model:'debit'
#                 recipient_id: @_id
#         Router.go "/debit/#{new_debit_id}/edit"

#     'click .request': ->
#         # user = Meteor.users.findOne(username:@username)
#         new_id =
#             Docs.insert
#                 model:'request'
#                 recipient_id: @_id
#         Router.go "/request/#{new_id}/edit"

# Template.addtoset_user.helpers
#     ats_class: ->
#         if Template.parentData()["#{@value}"] in @key
#             'blue'
#         else
#             ''

# Template.addtoset_user.events
#     'click .toggle_value': ->
#         Meteor.users.update Template.parentData(1)._id,
#             $addToSet:
#                 "#{@key}": @value





Template.rusers.helpers
    all_tags: -> results.find(model:'ruser_tag')
    selected_ruser_tags: -> selected_ruser_tags.array()
    # all_site: ->
    #     user_count = Meteor.users.find(_id:$ne:Meteor.userId()).count()
    #     if 0 < user_count < 3 then site.find { count: $lt: user_count } else sites.find()
    
    # all_sites: ->
    #     user_count = Meteor.users.find(_id:$ne:Meteor.userId()).count()
    #     if 0 < user_count < 3 then User_sites.find { count: $lt: user_count } else User_sites.find()
    # selected_user_sites: ->
    #     # model = 'event'
    #     selected_user_sites.array()
    # all_sites: ->
    #     user_count = Meteor.users.find(_id:$ne:Meteor.userId()).count()
    #     if 0 < user_count < 3 then site_results.find { count: $lt: user_count } else site_results.find()
    # selected_user_sites: ->
    #     # model = 'event'
    #     selected_user_sites.array()


        
Template.rusers.events
    'click .select_tag': -> 
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        selected_ruser_tags.push @name
    'click .unselect_tag': -> selected_ruser_tags.remove @valueOf()
    'click #clear_tags': -> selected_ruser_tags.clear()


    'click .clear_username': (e,t)-> 
        window.speechSynthesis.speak new SpeechSynthesisUtterance "clear username"
        Session.set('searching_username',null)

    'keyup .search_location': (e,t)->
        # search = $('.search_site').val().toLowerCase().trim()
        search = $('.search_location').val().trim()
        Session.set('location_query',search)
        if e.which is 13
            if search.length > 0
                window.speechSynthesis.cancel()
                window.speechSynthesis.speak new SpeechSynthesisUtterance search
                selected_tags.push search
                $('.search_site').val('')

                # Meteor.call 'search_stack', Router.current().params.site, search, ->
                #     Session.set('thinking',false)

