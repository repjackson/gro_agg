if Meteor.isClient
    Router.route '/shop', (->
        @layout 'layout'
        @render 'shop'
        ), name:'shop'
    Router.route '/s/:doc_id/edit', (->
        @layout 'layout'
        @render 'shop_edit'
        ), name:'shop_edit'
    Router.route '/s/:doc_id', (->
        @layout 'layout'
        @render 'shop_view'
        ), name:'shop_view'

    Template.shop_view.onCreated ->
        # @autorun => Meteor.subscribe 'product_from_shop_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    @picked_shop_tags = new ReactiveArray []
    # @picked_times = new ReactiveArray []
    # @picked_locations = new ReactiveArray []
    # @picked_authors = new ReactiveArray []
    
    Template.shop.onCreated ->
        Session.setDefault('sort_key', '_timestamp')
        Session.setDefault('sort_direction', -1)
        # Session.setDefault('location_query', null)
        @autorun => Meteor.subscribe 'shop_tags',
            picked_shop_tags.array()
            picked_times.array()
            picked_locations.array()
            picked_authors.array()
        @autorun => Meteor.subscribe 'shop_count', 
            picked_shop_tags.array()
            picked_times.array()
            picked_locations.array()
            picked_authors.array()
        @autorun => Meteor.subscribe 'shop_items', 
            picked_shop_tags.array()
            picked_times.array()
            picked_locations.array()
            picked_authors.array()
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('skip_value')
    

        
    Template.shop_edit.onCreated ->
        @autorun => Meteor.subscribe 'target_from_shop_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.shop.onCreated ->
        @autorun -> Meteor.subscribe 'products'
        # @autorun => Meteor.subscribe 'my_received_shops'
        # @autorun => Meteor.subscribe 'my_sent_shops'
        @autorun => Meteor.subscribe 'all_users'
        # @autorun => Meteor.subscribe 'model_docs', 'stat'

    Template.shop_item.helpers
        can_buy: -> Meteor.user().points > @karma_price
    
    
    Template.shop.helpers
        result_tags: -> results.find(model:'shop_tag')

        shop_items: ->
            Docs.find 
                model:'shop'
                # can_buy:true
                
                
    Template.shop_view.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'receipt'
    
                
    Template.shop_view.helpers
        receipts: ->
            Docs.find
                model:'receipt'
    Template.shop_view.events
        'click .buy': ->
            if confirm 'buy'
                Docs.insert 
                    parent_id:Router.current().params.doc_id
                    model:'receipt'
                Docs.update @_id, 
                    $inc:inventory:-1

    Template.shop.events
        'click .add_item': ->
            new_shop_id =
                Docs.insert
                    model:'shop'
            Router.go "/s/#{new_shop_id}/edit"

if Meteor.isServer
    Meteor.publish 'products', ()->
        Docs.find 
            model:'shop'
            # can_buy: true
            

    
    Meteor.publish 'shop_count', (
        picked_tags
        picked_authors
        picked_locations
        picked_times
        )->
        @unblock()
        match = {
            model:'shop'
            is_private:$ne:true
        }
        unless Meteor.userId()
            match.privacy='public'
    
            
        if picked_tags.length > 0 then match.tags = $all:picked_tags
        if picked_authors.length > 0 then match.author = $all:picked_authors
        if picked_locations.length > 0 then match.location = $all:picked_locations
        if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    
        Counts.publish this, 'doc_count', Docs.find(match)
        return undefined
                
    Meteor.publish 'shop_items', (
        picked_tags
        picked_times
        picked_locations
        picked_authors
        sort_key
        sort_direction
        skip=0
        )->
            
        @unblock()
        self = @
        match = {
            model:'shop'
            is_private:$ne:true
            group:$exists:false
        }
        unless Meteor.userId()
            match.privacy='public'
        
        if sort_key
            sk = sort_key
        else
            sk = '_timestamp'
        if picked_tags.length > 0 then match.tags = $all:picked_tags
        if picked_locations.length > 0 then match.location = $all:picked_locations
        if picked_authors.length > 0 then match.author = $all:picked_authors
        if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
    
        # console.log 'match',match
        Docs.find match,
            limit:10
            sort:_timestamp:-1
            # sort: "#{sk}":-1
            # skip:skip*20
            fields:
                title:1
                content:1
                tags:1
                upvoter_ids:1
                image_id:1
                image_link:1
                url:1
                youtube_id:1
                _timestamp:1
                _timestamp_tags:1
                views:1
                viewer_ids:1
                _author_username:1
                downvoter_ids:1
                _author_id:1
                model:1
        
        
    Meteor.publish 'shop_tags', (
        picked_tags
        picked_times
        picked_locations
        picked_authors
        # query=''
        )->
        # @unblock()
        self = @
        match = {
            # model:$in:['post','rpost']
            model:'shop'
            is_private:$ne:true
            # sublove:sublove
        }
    
    
        unless Meteor.userId()
            match.privacy='public'
    
        if picked_tags.length > 0 then match.tags = $all:picked_tags
        if picked_authors.length > 0 then match.author = $all:picked_authors
        if picked_locations.length > 0 then match.location = $all:picked_locations
        if picked_times.length > 0 then match.timestamp_tags = $all:picked_times
        doc_count = Docs.find(match).count()
        # console.log 'doc_count', doc_count
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:33 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        tag_cloud.forEach (tag, i) ->
            # console.log tag
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'shop_tag'
        
        location_cloud = Docs.aggregate [
            { $match: match }
            { $project: "location_tags": 1 }
            { $unwind: "$location_tags" }
            { $group: _id: "$location_tags", count: $sum: 1 }
            # { $match: _id: $nin: picked_location }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        location_cloud.forEach (location, i) ->
            self.added 'results', Random.id(),
                name: location.name
                count: location.count
                model:'shop_location_tag'
        
        
        timestamp_cloud = Docs.aggregate [
            { $match: match }
            { $project: "timestamp_tags": 1 }
            { $unwind: "$timestamp_tags" }
            { $group: _id: "$timestamp_tags", count: $sum: 1 }
            # { $match: _id: $nin: picked_time }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        # console.log match
        timestamp_cloud.forEach (time, i) ->
            # console.log 'time', time
            self.added 'results', Random.id(),
                name: time.name
                count: time.count
                model:'timestamp_tag'
        
        
        time_cloud = Docs.aggregate [
            { $match: match }
            { $project: "time_tags": 1 }
            { $unwind: "$time_tags" }
            { $group: _id: "$time_tags", count: $sum: 1 }
            # { $match: _id: $nin: picked_time }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        # console.log match
        timestamp_cloud.forEach (time, i) ->
            # console.log 'time', time
            self.added 'results', Random.id(),
                name: time.name
                count: time.count
                model:'time_tag'
        
        
        
        author_cloud = Docs.aggregate [
            { $match: match }
            { $project: "author": 1 }
            # { $unwind: "$author" }
            { $group: _id: "$author", count: $sum: 1 }
            { $match: _id: $nin: picked_authors }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit:10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        author_cloud.forEach (author, i) ->
            self.added 'results', Random.id(),
                name: author.name
                count: author.count
                model:'author'
        
        
        self.ready()
            