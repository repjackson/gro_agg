@selected_user_tags = new ReactiveArray []
# @selected_user_roles = new ReactiveArray []


Router.route '/susers', (->
    @render 'susers'
    ), name:'susers'

# Template.term_image.onCreated ->
Template.susers.onCreated ->
    Session.setDefault('selected_user_site',null)
    Session.setDefault('selected_user_location',null)
    Session.setDefault('searching_location',null)
    @autorun -> Meteor.subscribe 'selected_users', 
        selected_user_tags.array() 
        Session.get('selected_user_site')
        Session.get('selected_user_location')
        Session.get('searching_username')
        Session.get('location_query')
        Session.get('limit')

Template.susers.events
    'click .select_user': ->
        window.speechSynthesis.cancel()
        window.speechSynthesis.speak new SpeechSynthesisUtterance @display_name
    'keyup .search_username': (e,t)->
        val = $('.search_username').val()
        Session.set('searching_username',val)


Template.susers.helpers
    users: ->
        match = {model:'stackuser'}
        # unless 'admin' in Meteor.user().roles
        #     match.site = $in:['member']
        if selected_user_tags.array().length > 0 then match.tags = $all: selected_user_tags.array()
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




Template.susers.onCreated ->
    @autorun -> Meteor.subscribe('user_tags',
        selected_user_tags.array()
        Session.get('selected_user_site')
        Session.get('selected_user_location')
        Session.get('username_query')
        Session.get('location_query')
        # selected_user_roles.array()
        # Session.get('view_mode')
    )

Template.susers.helpers
    all_tags: -> results.find(model:'user_tag')
    all_sites: -> results.find({model:'user_site'},limit:10)
    all_locations: -> results.find({model:'user_location'},limit:10)
    
    current_location_query: -> Session.get('location_query')

    
    selected_user_site: -> Session.get('selected_user_site')
    selected_user_tags: -> selected_user_tags.array()
    selected_user_location: -> Session.get('selected_user_location')
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


        
Template.susers.events
    'click .select_tag': -> 
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        selected_user_tags.push @name
    'click .unselect_tag': -> selected_user_tags.remove @valueOf()
    'click #clear_tags': -> selected_user_tags.clear()

    'click .select_site': -> 
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
        Session.set('selected_user_site',@name)
    'click .unselect_site': -> Session.set('selected_user_site',null)
    
    'click .select_location': -> 
        Session.set('selected_user_location',@name)
        window.speechSynthesis.speak new SpeechSynthesisUtterance @name
    'click .unselect_location': -> Session.set('selected_user_location',null)
    # 'click #clear_sites': -> Session.set('selected_user_site',null)

    'click .clear_location': (e,t)-> 
        window.speechSynthesis.speak new SpeechSynthesisUtterance "location cleared"
        Session.set('location_query',null)

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

