if Meteor.isClient
    @selected_user_tags = new ReactiveArray []
    # @selected_user_roles = new ReactiveArray []


    Router.route '/tags', (->
        @render 'stack_tags'
        ), name:'stack_tags'


    Template.stack_tags.onCreated ->
        Session.setDefault('selected_user_site',null)
        Session.setDefault('selected_user_location',null)
        @autorun -> Meteor.subscribe 'selected_stack_tags', 
            selected_user_tags.array() 
            Session.get('selected_user_site')
            Session.get('selected_user_location')
            Session.get('limit')

    Template.stack_tags.events
        'click .select_user': ->
            window.speechSynthesis.cancel()
            window.speechSynthesis.speak new SpeechSynthesisUtterance @display_name

    Template.stack_tags.helpers
        tags: ->
            match = {model:'stack_tag'}
            # unless 'admin' in Meteor.user().roles
            #     match.site = $in:['member']
            if selected_user_tags.array().length > 0 then match.tags = $all: selected_user_tags.array()
            Docs.find match,
                sort:points:-1
            # if Meteor.user()
            #     if 'admin' in Meteor.user().roles
            #         Meteor.stack_tags.find()
            #     else
            #         Meteor.stack_tags.find(
            #             # site:$in:['l1']
            #             site:$in:['member']
            #         )
            # else
            #     Meteor.stack_tags.find(
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
    #         # user = Meteor.stack_tags.findOne(username:@username)
    #         new_debit_id =
    #             Docs.insert
    #                 model:'debit'
    #                 recipient_id: @_id
    #         Router.go "/debit/#{new_debit_id}/edit"

    #     'click .request': ->
    #         # user = Meteor.stack_tags.findOne(username:@username)
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
    #         Meteor.stack_tags.update Template.parentData(1)._id,
    #             $addToSet:
    #                 "#{@key}": @value




    Template.stack_tag_cloud.onCreated ->
        @autorun -> Meteor.subscribe('stack_tags',
            selected_user_tags.array()
            Session.get('selected_user_site')
            Session.get('selected_user_location')
            # selected_user_roles.array()
            # Session.get('view_mode')
        )

    Template.stack_tag_cloud.helpers
        all_tags: -> results.find(model:'user_tag')
        all_sites: -> results.find(model:'user_site')
        all_locations: -> results.find(model:'user_location')
        
        selected_user_site: -> Session.get('selected_user_site')
        selected_user_tags: -> selected_user_tags.array()
        selected_user_location: -> Session.get('selected_user_location')
        # all_site: ->
        #     user_count = Meteor.stack_tags.find(_id:$ne:Meteor.userId()).count()
        #     if 0 < user_count < 3 then site.find { count: $lt: user_count } else sites.find()

        # all_sites: ->
        #     user_count = Meteor.stack_tags.find(_id:$ne:Meteor.userId()).count()
        #     if 0 < user_count < 3 then User_sites.find { count: $lt: user_count } else User_sites.find()
        # selected_user_sites: ->
        #     # model = 'event'
        #     selected_user_sites.array()
        # all_sites: ->
        #     user_count = Meteor.stack_tags.find(_id:$ne:Meteor.userId()).count()
        #     if 0 < user_count < 3 then site_results.find { count: $lt: user_count } else site_results.find()
        # selected_user_sites: ->
        #     # model = 'event'
        #     selected_user_sites.array()


    Template.stack_tag_cloud.events
        'click .select_tag': -> selected_user_tags.push @name
        'click .unselect_tag': -> selected_user_tags.remove @valueOf()
        'click #clear_tags': -> selected_user_tags.clear()

        'click .select_site': -> Session.set('selected_user_site',@name)
        'click .unselect_site': -> Session.set('selected_user_site',null)
        
        'click .select_location': -> Session.set('selected_user_location',@name)
        'click .unselect_location': -> Session.set('selected_user_location',null)
        # 'click #clear_sites': -> Session.set('selected_user_site',null)



if Meteor.isServer
    Meteor.publish 'selected_stack_tags', (
        selected_user_tags
        selected_user_site
        selected_user_location
        )->
        match = {model:'stack_tag'}
        if selected_user_tags.length > 0 then match.tags = $all: selected_user_tags
        if selected_user_site then match.site = selected_user_site
        if selected_user_location then match.location = selected_user_location
        Docs.find match,
            limit:20



    Meteor.publish 'stack_tags', (
        selected_user_tags
        selected_user_site
        selected_user_location
        # view_mode
        # limit
    )->
        self = @
        match = {model:'stack_tag'}
        if selected_user_tags.length > 0 then match.tags = $all: selected_user_tags
        if selected_user_site then match.site = selected_user_site
        if selected_user_location then match.location = selected_user_location
        # match.model = 'item'
        # if view_mode is 'stack_tags'
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
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        cloud.forEach (user_tag, i) ->
            self.added 'user_tags', Random.id(),
                name: user_tag.name
                count: user_tag.count
                index: i
    
    
        site_cloud = Docs.aggregate [
            { $match: match }
            { $project: "site": 1 }
            { $group: _id: "$site", count: $sum: 1 }
            # { $match: site: $ne: selected_user_site }
            { $sort: count: -1, _id: 1 }
            { $limit: 42 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        site_cloud.forEach (site_result, i) ->
            self.added 'results', Random.id(),
                name: site_result.name
                model:'user_site'
                count: site_result.count
                index: i
        
        location_cloud = Docs.aggregate [
            { $match: match }
            { $project: "location": 1 }
            { $group: _id: "$location", count: $sum: 1 }
            # { $match: location: $ne: selected_user_location }
            { $sort: count: -1, _id: 1 }
            { $limit: 42 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        location_cloud.forEach (location_result, i) ->
            self.added 'results', Random.id(),
                name: location_result.name
                model:'user_location'
                count: location_result.count
                index: i

        self.ready()
