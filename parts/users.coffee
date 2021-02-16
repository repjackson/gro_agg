if Meteor.isClient
    @picked_user_tags = new ReactiveArray []
    @picked_user_roles = new ReactiveArray []


    Router.route '/users', (->
        @render 'users'
        ), name:'users'


    Template.users.onCreated ->
        @autorun -> Meteor.subscribe 'picked_users', 
            picked_user_tags.array() 
            picked_user_roles.array()

    Template.users.helpers
        users: ->
            match = {}
            # unless 'admin' in Meteor.user().roles
            #     match.roles = $in:['member']
            if picked_user_tags.array().length > 0 then match.tags = $all: picked_user_tags.array()
            if picked_user_roles.array().length > 0 then match.roles = $all: picked_user_roles.array()
            Meteor.users.find match,
                sort:points:-1
            # if Meteor.user()
            #     if 'admin' in Meteor.user().roles
            #         Meteor.users.find()
            #     else
            #         Meteor.users.find(
            #             # roles:$in:['l1']
            #             roles:$in:['member']
            #         )
            # else
            #     Meteor.users.find(
            #         roles:$in:['member']
            #     )

    Template.member_card.helpers
        credit_ratio: ->
            unless @debit_count is 0
                @debit_count/@debit_count

    Template.member_card.events
        'click .calc_points': ->
            Meteor.call 'calc_user_points', @_id, ->
        'click .debit': ->
            # user = Meteor.users.findOne(username:@username)
            new_debit_id =
                Docs.insert
                    model:'debit'
                    recipient_id: @_id
            Router.go "/debit/#{new_debit_id}/edit"

        'click .request': ->
            # user = Meteor.users.findOne(username:@username)
            new_id =
                Docs.insert
                    model:'request'
                    recipient_id: @_id
            Router.go "/request/#{new_id}/edit"

    Template.addtoset_user.helpers
        ats_class: ->
            # console.log Templat
            if Template.parentData()["#{@value}"] in @key
                # console.log 'yes'
                'blue'
            else
                # console.log 'oh god no'
                ''

    Template.user_item.events
        'click .profile': ->
            $('.global_container')
                .transition('fade right', 500)
                # .transition('fade in', 200)
            console.log @
            Meteor.setTimeout =>
                Router.go "/u/#{@username}"
            , 500

    Template.addtoset_user.events
        'click .toggle_value': ->
            # console.log @
            # console.log Template.parentData(1)
            Meteor.users.update Template.parentData(1)._id,
                $addToSet:
                    "#{@key}": @value




    Template.user_cloud.onCreated ->
        @autorun -> Meteor.subscribe('user_tags',
            picked_user_tags.array()
            picked_user_roles.array()
            picked_user_roles.array()
            Session.get('view_mode')
        )

    Template.user_cloud.helpers
        all_tags: ->
            user_count = Meteor.users.find(_id:$ne:Meteor.userId()).count()
            if 0 < user_count < 3 then results.find { model:'user_tag', count: $lt: user_count } else results.find(model:'user_tag')
        picked_user_tags: ->
            # model = 'event'
            # console.log "pickeded_#{model}_tags"
            picked_user_tags.array()
        all_roles: ->
            user_count = Meteor.users.find(_id:$ne:Meteor.userId()).count()
            if 0 < user_count < 3 then results.find { model:'user_role', count: $lt: user_count } else results.find(model:'user_role')

        picked_user_roles: ->
            # model = 'event'
            # console.log "pickeded_#{model}_roles"
            picked_user_roles.array()


    Template.user_cloud.events
        'click .pick_tag': -> picked_user_tags.push @name
        'click .unpick_tag': -> picked_user_tags.remove @valueOf()
        'click #clear_tags': -> picked_user_tags.clear()

        'click .pick_role': -> picked_user_roles.push @name
        'click .unpick_role': -> picked_user_roles.remove @valueOf()
        'click #clear_roles': -> picked_user_roles.clear()



if Meteor.isServer
    Meteor.publish 'picked_users', (
        picked_user_tags
        picked_user_roles
        )->
        match = {}
        if picked_user_tags.length > 0 then match.tags = $all: picked_user_tags
        if picked_user_roles.length > 0 then match.roles = $all: picked_user_roles
        Meteor.users.find match,
            fields:
                username:1
                profile_image_id:1
                theme_color:1
                one_ratio:1
                points:1
                flow_volume:1
                roles:1
                tags:1
        # if Meteor.user()
        #     if 'admin' in Meteor.user().roles
        #         Meteor.users.find()
        #     else
        #         Meteor.users.find(
        #             # roles:$in:['l1']
        #             roles:$in:['member']
        #         )
        # else
        #     Meteor.users.find(
        #         roles:$in:['member']
        #     )



    Meteor.publish 'user_tags', (
        picked_user_tags,
        picked_user_roles,
        view_mode
        limit
    )->
        self = @
        match = {}
        if picked_user_tags.length > 0 then match.tags = $all: picked_user_tags
        if picked_user_roles.length > 0 then match.roles = $all: picked_user_roles
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

        cloud = Meteor.users.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_user_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud

        cloud.forEach (user_tag, i) ->
            self.added 'results', Random.id(),
                name: user_tag.name
                count: user_tag.count
                model:'user_tag'
                index: i
    
    
        role_cloud = Meteor.users.aggregate [
            { $match: match }
            { $project: "roles": 1 }
            { $unwind: "$roles" }
            { $group: _id: "$roles", count: $sum: 1 }
            { $match: _id: $nin: picked_user_roles }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        # console.log 'filter: ', filter
        # console.log 'role_cloud: ', role_cloud

        role_cloud.forEach (role_result, i) ->
            self.added 'results', Random.id(),
                name: role_result.name
                count: role_result.count
                index: i
                model:'user_role'

        self.ready()
