if Meteor.isClient
    Router.route '/tribe/:name', (->
        @layout 'layout'
        @render 'tribe_view'
        ), name:'tribe_view'
    Router.route '/tribe/:name/edit', (->
        @layout 'layout'
        @render 'tribe_edit'
        ), name:'tribe_edit'
    Router.route '/tribes/', (->
        @layout 'layout'
        @render 'tribes'
        ), name:'tribes'
    
    Template.tribes.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'tribe'
    Template.tribes.helpers
        tribes: ->
            Docs.find({
                model:'tribe'
            }, sort:_timestamp:-1)
    
        
        

    Template.tribe_edit.onCreated ->
        @autorun => Meteor.subscribe 'tribe_by_name', Router.current().params.name
        @autorun => Meteor.subscribe 'tribe_members', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'feature'
        

    Template.registerHelper 'is_member', ()->
        Meteor.userId() in @member_ids

    Template.tribe_posts.onRendered ->
        @autorun => Meteor.subscribe 'tribe_posts', 
            Router.current().params.name
            selected_tribe_tags.array()
            selected_tribe_location_tags.array()
            selected_tribe_time_tags.array()
            selected_tribe_people_tags.array()
            Session.get('tribe_limit')
            Session.get('tribe_sort_key')
            Session.get('tribe_sort_direction')
    @selected_tribe_tags = new ReactiveArray []
    @selected_tribe_location_tags = new ReactiveArray []
    @selected_tribe_time_tags = new ReactiveArray []
    @selected_tribe_people_tags = new ReactiveArray []

    Template.tribe_posts.onCreated ->
        @autorun -> Meteor.subscribe('tribe_tags', 
            selected_tribe_tags.array(), 
            selected_tribe_location_tags.array()
            selected_tribe_time_tags.array()
            selected_tribe_people_tags.array()
            Template.currentData().limit
        )

    Template.tribe_posts.helpers
        all_tags: -> results.find(model:'tribe_tag')
        all_location_tags: -> results.find(model:'tribe_location_tag')
        all_time_tags: -> results.find(model:'tribe_time_tag')
        all_people_tags: -> results.find(model:'tribe_people_tag')

        selected_tribe_tags: -> selected_tribe_tags.array()
        selected_tribe_location_tags: -> selected_tribe_location_tags.array()
        selected_tribe_time_tags: -> selected_tribe_time_tags.array()
        selected_tribe_people_tags: -> selected_tribe_people_tags.array()

        posts: ->
            # tribe = Docs.findOne 
            #     model:'tribe'
            #     name:Router.current().params.name
            Docs.find({
                model:'post'
                tribe:Router.current().params.name
                published:true
            }, sort:_timestamp:-1)
    

    Template.tribe_post_card.events
        'click .pick_tag': -> selected_tribe_tags.push @valueOf()
        # 'click .unselect_tag': -> selected_tribe_tags.remove @valueOf()

        'click .pick_location': -> selected_tribe_location_tags.push @valueOf()
        # 'click .unselect_location_tag': -> selected_tribe_location_tags.remove @valueOf()

        'click .pick_time': -> selected_tribe_time_tags.push @valueOf()
        # 'click .unselect_time_tag': -> selected_tribe_time_tags.remove @valueOf()

        'click .pick_person': -> selected_tribe_people_tags.push @valueOf()
        # 'click .unselect_people_tag': -> selected_tribe_people_tags.remove @valueOf()



    Template.tribe_posts.events
        'click .select_tag': -> selected_tribe_tags.push @name
        'click .unselect_tag': -> selected_tribe_tags.remove @valueOf()
        'click #clear_tags': -> selected_tribe_tags.clear()

        'click .select_location_tag': -> selected_tribe_location_tags.push @name
        'click .unselect_location_tag': -> selected_tribe_location_tags.remove @valueOf()
        'click #clear_location_tags': -> selected_tribe_location_tags.clear()

        'click .select_time_tag': -> selected_tribe_time_tags.push @name
        'click .unselect_time_tag': -> selected_tribe_time_tags.remove @valueOf()
        'click #clear_time_tags': -> selected_tribe_time_tags.clear()

        'click .select_people_tag': -> selected_tribe_people_tags.push @name
        'click .unselect_people_tag': -> selected_tribe_people_tags.remove @valueOf()
        'click #clear_people_tags': -> selected_tribe_people_tags.clear()


  
  
            
    Template.tribe_edit.events
        'click .enable_feature': ->
            console.log @
            Docs.update Router.current().params.doc_id,
                $addToSet: 
                    enabled_feature_ids:@_id
    
        'click .disable_feature': ->
            Docs.update Router.current().params.doc_id,
                $pull: 
                    enabled_feature_ids:@_id
    
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_tribe', @_id, =>
                    Router.go "/tribe/#{@_id}/view"

    Template.tribe_membership.helpers
        members: ->
            tribe = 
                Docs.findOne
                    model:'tribe'
                    
            Meteor.users.find
                _id:$in:tribe.member_ids
            
    Template.tribe_membership.events
        'click .switch': ->
            Meteor.call 'switch_tribe', @_id
        'click .join': ->
            if Meteor.userId()
                Meteor.call 'join_tribe', @_id, ->
            else 
                Router.go "/register"
        'click .leave': ->
            Meteor.call 'leave_tribe', @_id, ->
        'click .request': ->
            Meteor.call 'request_tribe_membership', @_id, ->
                
    Template.tribe_member_item.events
        'click .tip': ->
            if confirm 'tip user?'
                Meteor.call 'tip_user', @_id, ->

if Meteor.isServer
    Meteor.publish 'tribe_tags', (
        selected_tribe_tags, 
        selected_tribe_location_tags, 
        selected_tribe_time_tags, 
        selected_tribe_people_tags, 
        limit
        )->
        self = @
        match = {model:'post', tribe:'jpfam', published:true}
        if selected_tribe_tags.length > 0 then match.tags = $all: selected_tribe_tags
        if selected_tribe_location_tags.length > 0 then match.location_tags = $all: selected_tribe_location_tags
        if selected_tribe_time_tags.length > 0 then match.time_tags = $all: selected_tribe_time_tags
        if selected_tribe_people_tags.length > 0 then match.people_tags = $all: selected_tribe_people_tags
        # if limit
        #     calc_limit = limit
        # else
        #     calc_limit = 20
        doc_count = Docs.find(match).count()
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tribe_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tribe_tag'
        location_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "location_tags": 1 }
            { $unwind: "$location_tags" }
            { $group: _id: "$location_tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tribe_location_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        location_tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tribe_location_tag'

        time_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "time_tags": 1 }
            { $unwind: "$time_tags" }
            { $group: _id: "$time_tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tribe_time_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        time_tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tribe_time_tag'
        
        people_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "people_tags": 1 }
            { $unwind: "$people_tags" }
            { $group: _id: "$people_tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tribe_people_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        people_tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tribe_people_tag'
        self.ready()    

    Meteor.publish 'tribe_posts', (
        name, 
        selected_tribe_tags
        selected_tribe_location_tags
        selected_tribe_time_tags
        selected_tribe_people_tags
        limit=10
        sort_key='_timestamp'
        sort_direction=-1
        )->
        match = {model:'post', tribe:'jpfam', published:true}
        if selected_tribe_tags.length > 0 then match.tags = $all: selected_tribe_tags
        if selected_tribe_location_tags.length > 0 then match.location_tags = $all: selected_tribe_location_tags
        if selected_tribe_time_tags.length > 0 then match.time_tags = $all: selected_tribe_time_tags
        if selected_tribe_people_tags.length > 0 then match.people_tags = $all: selected_tribe_people_tags

        Docs.find match,
            limit:10
            sort:
                "#{sort_key}":sort_direction
            limit:limit
    Meteor.publish 'tribe_by_name', (name)->
        Docs.find
            model:'tribe'
            name:name
            
            
    Meteor.publish 'tribe_members', (name)->
        tribe = Docs.findOne 
            model:'tribe'
            name:name
        if tribe 
            Meteor.users.find
                _id:$in:tribe.member_ids
        else 
            tribe_doc = Docs.findOne
                model:'tribe'
                _id:name
            Meteor.users.find
                _id:$in:tribe_doc.member_ids
            
    
    
    Meteor.methods
        tip_user: (target_id)->
            target = Meteor.users.findOne target_id
            # console.log 'target', target
            console.log 'tip user', target_id
            
            Docs.insert 
                model:'tip'
                _target_id: target_id
                _target_username:target.username
            Meteor.call 'calc_tips', target_id, ->
            Meteor.call 'calc_tips', Meteor.userId(), ->
            
            
        calc_tips: (user_id)->
            console.log 'calc tips', user_id
            user = Meteor.users.findOne user_id
            tips_given_count = 
                Docs.find( 
                    model:'tip'
                    _author_id:user_id
                ).count()
                
            tips_received_count = 
                Docs.find( 
                    model:'tip'
                    _target_id:user_id
                ).count()
            
            total_points = tips_received_count*10 - tips_given_count*11    
                
            Meteor.users.update user_id,
                $set:
                    "stats.tips_received_count":tips_received_count
                    "stats.tips_given_count":tips_given_count
                    "stats.points":total_points
            
        join_tribe: (tribe_id)->
            tribe = Docs.findOne tribe_id
            Docs.update tribe_id, 
                $addToSet:
                    member_ids: Meteor.userId()
        
        leave_tribe: (tribe_id)->
            tribe = Docs.findOne tribe_id
            Docs.update tribe_id, 
                $pull:
                    member_ids: Meteor.userId()
                    
                    
        # switch_tribe: (tribe_id)->
        #     Meteor.users.update Meteor.userId(),
        #         $set:current_tribe_id:tribe_id

if Meteor.isClient
    Template.tribe_edit.events
        'click .delete_item': ->
            if confirm 'delete tribe?'
                Meteor.call 'delete_tribe', @_id, ->

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_tribe', @_id, =>
                    Router.go "/tribe/#{@_id}/view"


    # Template.tribe_edit.helpers
    #     unselected_stewards: ->
    #         Meteor.users.find 
    #             levels:$in:['steward']


