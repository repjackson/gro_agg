if Meteor.isClient
    @selected_user_tags = new ReactiveArray []
    @selected_user_roles = new ReactiveArray []


    Router.route '/users', (->
        @render 'users'
        ), name:'users'


    Template.users.onCreated ->
        Session.setDefault('selected_site',null)
        @autorun -> Meteor.subscribe 'selected_users', 
            selected_user_tags.array() 
            Session.get('selected_site')

    Template.users.helpers
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
    #         # console.log Templat
    #         if Template.parentData()["#{@value}"] in @key
    #             # console.log 'yes'
    #             'blue'
    #         else
    #             # console.log 'oh god no'
    #             ''

    # Template.addtoset_user.events
    #     'click .toggle_value': ->
    #         console.log @
    #         console.log Template.parentData(1)
    #         Meteor.users.update Template.parentData(1)._id,
    #             $addToSet:
    #                 "#{@key}": @value




    Template.user_cloud.onCreated ->
        @autorun -> Meteor.subscribe('user_tags',
            selected_user_tags.array()
            Session.get('selected_user_site')
            # selected_user_roles.array()
            # Session.get('view_mode')
        )

    Template.user_cloud.helpers
        all_tags: ->
            # user_count = Docs.find(_id:$ne:Meteor.userId()).count()
            # if 0 < user_count < 3 then User_tags.find { count: $lt: user_count } else User_tags.find()
            results.find(model:'user_tag')
        all_sites: ->
            # user_count = Docs.find(_id:$ne:Meteor.userId()).count()
            # if 0 < user_count < 3 then User_tags.find { count: $lt: user_count } else User_tags.find()
            results.find(model:'user_site')
        
        selected_user_site: -> Session.get('selected_user_site')
        selected_user_tags: -> selected_user_tags.array()
        # all_site: ->
        #     user_count = Meteor.users.find(_id:$ne:Meteor.userId()).count()
        #     if 0 < user_count < 3 then site.find { count: $lt: user_count } else sites.find()

        # all_sites: ->
        #     user_count = Meteor.users.find(_id:$ne:Meteor.userId()).count()
        #     if 0 < user_count < 3 then User_sites.find { count: $lt: user_count } else User_sites.find()
        # selected_user_sites: ->
        #     # model = 'event'
        #     # console.log "selected_#{model}_sites"
        #     selected_user_sites.array()
        # all_sites: ->
        #     user_count = Meteor.users.find(_id:$ne:Meteor.userId()).count()
        #     if 0 < user_count < 3 then site_results.find { count: $lt: user_count } else site_results.find()
        # selected_user_sites: ->
        #     # model = 'event'
        #     # console.log "selected_#{model}_sites"
        #     selected_user_sites.array()


    Template.user_cloud.events
        'click .select_tag': -> selected_user_tags.push @name
        'click .unselect_tag': -> selected_user_tags.remove @valueOf()
        'click #clear_tags': -> selected_user_tags.clear()

        'click .select_site': -> selected_user_sites.push @name
        'click .unselect_site': -> selected_user_sites.remove @valueOf()
        'click #clear_sites': -> selected_user_sites.clear()



if Meteor.isServer
    Meteor.publish 'selected_users', (
        selected_user_tags
        selected_user_site
        )->
        match = {model:'stackuser'}
        if selected_user_tags.length > 0 then match.tags = $all: selected_user_tags
        if selected_user_site then match.site = selected_user_site
        Docs.find match
        # if Meteor.user()
        #     if 'admin' in Meteor.user().roles
        #         Meteor.users.find()
        #     else
        #         Meteor.users.find(
        #             # sites:$in:['l1']
        #             roles:$in:['member']
        #         )
        # else
        #     Meteor.users.find(
        #         sites:$in:['member']
        #     )



    Meteor.publish 'user_tags', (
        selected_user_tags
        selected_user_site
        # view_mode
        # limit
    )->
        self = @
        match = {model:'stackuser'}
        if selected_user_tags.length > 0 then match.tags = $all: selected_user_tags
        if selected_user_site then match.site = selected_user_site
        # match.model = 'item'
        # if view_mode is 'users'
        #     match.bought = $ne:true
        #     match._author_id = $ne: Meteor.userId()
        # if view_mode is 'bought'
        #     match.bought = true
        #     match.buyer_id = Meteor.userId()
        # if view_mode is 'selling'
        #     match.bought = $ne:true
        #     match._author_id = Meteor.userId()
        # if view_mode is 'sold'
        #     match.bought = true
        #     match._author_id = Meteor.userId()

        cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_user_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud

        cloud.forEach (user_tag, i) ->
            self.added 'user_tags', Random.id(),
                name: user_tag.name
                count: user_tag.count
                index: i
    
    
        site_cloud = Docs.aggregate [
            { $match: match }
            { $project: "site": 1 }
            { $group: _id: "$site", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        # console.log 'filter: ', filter
        # console.log 'site_cloud: ', site_cloud

        site_cloud.forEach (site_result, i) ->
            self.added 'results', Random.id(),
                name: site_result.name
                model:'user_site'
                count: site_result.count
                index: i

        self.ready()
