if Meteor.isClient
    Router.route '/groups/', (->
        @layout 'layout'
        @render 'groups'
        ), name:'groups'
    

    Router.route '/group/:doc_id/view', (->
        @layout 'layout'
        @render 'group_view'
        ), name:'group_view'

    Router.route '/group/:name', (->
        @layout 'layout'
        @render 'group_view'
        ), name:'group_view_name'
    
    Router.route '/g/:name', (->
        @layout 'layout'
        @render 'group_view'
        ), name:'group_view_name_short'
    

    Template.group_view.onCreated ->
        Session.setDefault('view_section', 'posts')
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_by_name', Router.current().params.name
        @autorun => Meteor.subscribe 'group_docs', Router.current().params.name
        @autorun => Meteor.subscribe 'group_members',Router.current().params.name
        @autorun => Meteor.subscribe 'product_from_group_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
        # @autorun => Meteor.subscribe 'group_template_from_group_id', Router.current().params.doc_id

    Template.group_edit.onCreated ->
        # @autorun => Meteor.subscribe 'group_by_name', Router.current().params.name
        @autorun => Meteor.subscribe 'group_members', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'feature'
        @autorun => Meteor.subscribe 'recipient_from_group_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users', Router.current().params.doc_id
       
        @autorun => @subscribe 'tag_results',
            # Router.current().params.doc_id
            selected_tags.array()
            Session.get('searching')
            Session.get('current_query')
            Session.get('dummy')






            
if Meteor.isClient
    Router.route '/g/:doc_id/edit', (->
        @layout 'layout'
        @render 'group_edit'
        ), name:'group_edit'
        
        
        
    Template.group_edit.onRendered ->


    Template.group_edit.helpers
        terms: ->
            Terms.find()
        suggestions: ->
            Tags.find()
        recipient: ->
            group = Docs.findOne Router.current().params.doc_id
            if group.target_id
                Meteor.users.findOne
                    _id: group.target_id
        members: ->
            group = Docs.findOne Router.current().params.doc_id
            Meteor.users.find({
                # levels: $in: ['member','domain']
                _id: $ne: Meteor.userId()
            }, {
                sort:points:1
                limit:10
                })
        # subtotal: ->
        #     group = Docs.findOne Router.current().params.doc_id
        #     group.amount*group.target_ids.length
        
        point_max: ->
            if Meteor.user().username is 'one'
                1000
            else 
                Meteor.user().points
        
        can_submit: ->
            group = Docs.findOne Router.current().params.doc_id
            group.amount and group.target_id
    Template.group_edit.events
        'click .add_recipient': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    target_id:@_id
        'click .remove_recipient': ->
            Docs.update Router.current().params.doc_id,
                $unset:
                    target_id:1
        'keyup .new_tag': _.throttle((e,t)->
            query = $('.new_tag').val()
            if query.length > 0
                Session.set('searching', true)
            else
                Session.set('searching', false)
            Session.set('current_query', query)
            
            if e.which is 13
                element_val = t.$('.new_tag').val().toLowerCase().trim()
                Docs.update Router.current().params.doc_id,
                    $addToSet:tags:element_val
                selected_tags.push element_val
                Meteor.call 'log_term', element_val, ->
                Session.set('searching', false)
                Session.set('current_query', '')
                Session.set('dummy', !Session.get('dummy'))
                t.$('.new_tag').val('')
        , 1000)

        'click .remove_element': (e,t)->
            element = @valueOf()
            field = Template.currentData()
            selected_tags.remove element
            Docs.update Router.current().params.doc_id,
                $pull:tags:element
            t.$('.new_tag').focus()
            t.$('.new_tag').val(element)
            Session.set('dummy', !Session.get('dummy'))
    
    
        'click .select_term': (e,t)->
            # selected_tags.push @title
            Docs.update Router.current().params.doc_id,
                $addToSet:tags:@title
            selected_tags.push @title
            $('.new_tag').val('')
            Session.set('current_query', '')
            Session.set('searching', false)
            Session.set('dummy', !Session.get('dummy'))

    
        'blur .edit_description': (e,t)->
            textarea_val = t.$('.edit_textarea').val()
            Docs.update Router.current().params.doc_id,
                $set:description:textarea_val
    
    
        'blur .edit_text': (e,t)->
            val = t.$('.edit_text').val()
            Docs.update Router.current().params.doc_id,
                $set:"#{@key}":val
    
    
        'blur .point_amount': (e,t)->
            # console.log @
            val = parseInt t.$('.point_amount').val()
            Docs.update Router.current().params.doc_id,
                $set:amount:val



        'click .cancel_group': ->
            Swal.fire({
                title: "confirm cancel?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonColor: 'red'
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Router.go '/'
            )
            
        'click .submit': ->
            Swal.fire({
                title: "confirm send #{@amount}pts?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonColor: 'green'
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'send_group', @_id, =>
                        Swal.fire(
                            title:"#{@amount} sent"
                            icon:'success'
                            showConfirmButton: false
                            position: 'top-end',
                            timer: 1000
                        )
                        Router.go "/g/#{@_id}/view"
            )



if Meteor.isServer
    Meteor.methods
        send_group: (group_id)->
            group = Docs.findOne group_id
            recipient = Meteor.users.findOne group.target_id
            grouper = Meteor.users.findOne group._author_id

            console.log 'sending group', group
            Meteor.call 'recalc_one_stats', recipient._id, ->
            Meteor.call 'recalc_one_stats', group._author_id, ->
    
            Docs.update group_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()
            return
            
            
if Meteor.isClient
    Template.groups.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'group'
    Template.groups.helpers
        groups: ->
            Docs.find({
                model:'group'
            }, sort:_timestamp:-1)
    
    @selected_group_tags = new ReactiveArray []
    @selected_group_location_tags = new ReactiveArray []
    @selected_group_time_tags = new ReactiveArray []
    @selected_group_people_tags = new ReactiveArray []
        
        

    Template.registerHelper 'is_member', ()->
        Meteor.userId() in @member_ids

    Template.group_posts.onRendered ->
        @autorun => Meteor.subscribe 'group_posts', 
            Router.current().params.name
            selected_group_tags.array()
            selected_group_location_tags.array()
            selected_group_time_tags.array()
            selected_group_people_tags.array()
            Session.get('group_limit')
            Session.get('group_sort_key')
            Session.get('group_sort_direction')

    Template.group_posts.onCreated ->
        @autorun -> Meteor.subscribe('group_tags', 
            Router.current().params.name,
            selected_group_tags.array(), 
            selected_group_location_tags.array()
            selected_group_time_tags.array()
            selected_group_people_tags.array()
            Template.currentData().limit
        )

    Template.group_posts.helpers
        all_tags: -> results.find(model:'group_tag')
        all_location_tags: -> results.find(model:'group_location_tag')
        all_time_tags: -> results.find(model:'group_time_tag')
        all_people_tags: -> results.find(model:'group_people_tag')

        selected_group_tags: -> selected_group_tags.array()
        selected_group_location_tags: -> selected_group_location_tags.array()
        selected_group_time_tags: -> selected_group_time_tags.array()
        selected_group_people_tags: -> selected_group_people_tags.array()

        posts: ->
            group = Docs.findOne 
                model:'group'
                name:Router.current().params.name
            Docs.find({
                model:'post'
                group:Router.current().params.name
                # published:true
            }, sort:_timestamp:-1)
    
        grid_class: -> if Session.equals('group_view_layout', 'grid') then 'black' else 'basic'
        list_class: -> if Session.equals('group_view_layout', 'list') then 'black' else 'basic'
   
   
    Template.group_view.onRendered ->
        @autorun => Meteor.subscribe 'group_members', Router.current().params.name
    Template.group_view.events
        'click .create_group': ->
            # console.log 'creating'
            Docs.insert 
                model:'group'
                name:Router.current().params.name

    Template.group_post_card.events
        'click .pick_tag': -> selected_group_tags.push @valueOf()
        # 'click .unselect_tag': -> selected_group_tags.remove @valueOf()

        'click .pick_location': -> selected_group_location_tags.push @valueOf()
        # 'click .unselect_location_tag': -> selected_group_location_tags.remove @valueOf()

        'click .pick_time': -> selected_group_time_tags.push @valueOf()
        # 'click .unselect_time_tag': -> selected_group_time_tags.remove @valueOf()

        'click .pick_person': -> selected_group_people_tags.push @valueOf()
        # 'click .unselect_people_tag': -> selected_group_people_tags.remove @valueOf()



    Template.group_posts.events
        'click .select_tag': -> selected_group_tags.push @name
        'click .unselect_tag': -> selected_group_tags.remove @valueOf()
        'click #clear_tags': -> selected_group_tags.clear()

        'click .select_location_tag': -> selected_group_location_tags.push @name
        'click .unselect_location_tag': -> selected_group_location_tags.remove @valueOf()
        'click #clear_location_tags': -> selected_group_location_tags.clear()

        'click .select_time_tag': -> selected_group_time_tags.push @name
        'click .unselect_time_tag': -> selected_group_time_tags.remove @valueOf()
        'click #clear_time_tags': -> selected_group_time_tags.clear()

        'click .select_people_tag': -> selected_group_people_tags.push @name
        'click .unselect_people_tag': -> selected_group_people_tags.remove @valueOf()
        'click #clear_people_tags': -> selected_group_people_tags.clear()

        'click .create_post': ->
            new_id = Docs.insert
                model:'post'
                group:Router.current().params.name
            Router.go "/p/#{new_id}/edit"
        'click .sort_timestamp': (e,t)-> Session.set('group_sort_key','_timestamp')
        'click .unview_bounties': (e,t)-> Session.set('view_bounties',0)
        'click .view_bounties': (e,t)-> Session.set('view_bounties',1)
        'click .unview_unanswered': (e,t)-> Session.set('view_unanswered',0)
        'click .view_unanswered': (e,t)-> Session.set('view_unanswered',1)
        'click .sort_down': (e,t)-> Session.set('group_sort_direction',-1)
        'click .sort_up': (e,t)-> Session.set('group_sort_direction',1)
        'click .toggle_detail': (e,t)-> Session.set('view_detail',!Session.get('view_detail'))
        'click .limit_10': (e,t)-> Session.set('group_limit',10)
        'click .limit_1': (e,t)-> Session.set('group_limit',1)
        'click .set_grid': (e,t)-> Session.set('group_view_layout', 'grid')
        'click .set_list': (e,t)-> Session.set('group_view_layout', 'list')
        'keyup .search_site': (e,t)->
            # search = $('.search_site').val().toLowerCase().trim()
            search = $('.search_site').val().trim()
            if e.which is 13
                if search.length > 0
                    window.speechSynthesis.cancel()
                    window.speechSynthesis.speak new SpeechSynthesisUtterance search
                    selected_tags.push search
                    $('.search_site').val('')
    
                    Session.set('loading',true)
                    Meteor.call 'search_stack', Router.current().params.site, search, ->
                        Session.set('loading',false)

  
  
            
    Template.group_edit.events
        # 'click .enable_feature': ->
        #     console.log @
        #     Docs.update Router.current().params.doc_id,
        #         $addToSet: 
        #             enabled_feature_ids:@_id
    
        # 'click .disable_feature': ->
        #     Docs.update Router.current().params.doc_id,
        #         $pull: 
        #             enabled_feature_ids:@_id
    
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            if confirm 'confirm?'
                Meteor.call 'send_group', @_id, =>
                    Router.go "/g/#{@_id}/view"

    Template.group_membership.helpers
        members: ->
            group = 
                Docs.findOne
                    model:'group'
                    
            Meteor.users.find
                _id:$in:group.member_ids
            
    Template.group_membership.events
        'click .switch': ->
            Meteor.call 'switch_group', @_id
        'click .join': ->
            if Meteor.userId()
                Meteor.call 'join_group', @_id, ->
            else 
                Router.go "/register"
        'click .leave': ->
            Meteor.call 'leave_group', @_id, ->
        'click .request': ->
            Meteor.call 'request_group_membership', @_id, ->
                
    Template.group_member_item.events
        'click .tip': ->
            if confirm 'tip user?'
                Meteor.call 'tip_user', @_id, ->

if Meteor.isServer
    Meteor.publish 'group_tags', (
        name
        selected_group_tags, 
        selected_group_location_tags, 
        selected_group_time_tags, 
        selected_group_people_tags, 
        limit
        )->
        console.log 'group tags'
        self = @
        match = {model:'post', group:name}
        if selected_group_tags.length > 0 then match.tags = $all: selected_group_tags
        if selected_group_location_tags.length > 0 then match.location_tags = $all: selected_group_location_tags
        if selected_group_time_tags.length > 0 then match.time_tags = $all: selected_group_time_tags
        if selected_group_people_tags.length > 0 then match.people_tags = $all: selected_group_people_tags
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
            { $match: _id: $nin: selected_group_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'group_tag'
        location_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "location_tags": 1 }
            { $unwind: "$location_tags" }
            { $group: _id: "$location_tags", count: $sum: 1 }
            { $match: _id: $nin: selected_group_location_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        location_tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'group_location_tag'

        time_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "time_tags": 1 }
            { $unwind: "$time_tags" }
            { $group: _id: "$time_tags", count: $sum: 1 }
            { $match: _id: $nin: selected_group_time_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        time_tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'group_time_tag'
        
        people_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "people_tags": 1 }
            { $unwind: "$people_tags" }
            { $group: _id: "$people_tags", count: $sum: 1 }
            { $match: _id: $nin: selected_group_people_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: doc_count }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        people_tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'group_people_tag'
        self.ready()    

    Meteor.publish 'group_posts', (
        name, 
        selected_group_tags
        selected_group_location_tags
        selected_group_time_tags
        selected_group_people_tags
        limit=10
        sort_key='_timestamp'
        sort_direction=-1
        )->
        match = {model:'post', group:name}
        if selected_group_tags.length > 0 then match.tags = $all: selected_group_tags
        if selected_group_location_tags.length > 0 then match.location_tags = $all: selected_group_location_tags
        if selected_group_time_tags.length > 0 then match.time_tags = $all: selected_group_time_tags
        if selected_group_people_tags.length > 0 then match.people_tags = $all: selected_group_people_tags

        Docs.find match,
            limit:10
            sort:
                "#{sort_key}":sort_direction
            # limit:limit
    Meteor.publish 'group_by_name', (name)->
        Docs.find
            model:'group'
            name:name
            
            
    Meteor.publish 'group_members', (name)->
        group = Docs.findOne 
            model:'group'
            name:name
        if group 
            Meteor.users.find
                _id:$in:group.member_ids
        else 
            group_doc = Docs.findOne
                model:'group'
                _id:name
            Meteor.users.find
                _id:$in:group_doc.member_ids
            
    
    
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
            
        join_group: (group_id)->
            group = Docs.findOne group_id
            Docs.update group_id, 
                $addToSet:
                    member_ids: Meteor.userId()
        
        leave_group: (group_id)->
            group = Docs.findOne group_id
            Docs.update group_id, 
                $pull:
                    member_ids: Meteor.userId()
                    
                    
        # switch_group: (group_id)->
        #     Meteor.users.update Meteor.userId(),
        #         $set:current_group_id:group_id

if Meteor.isClient
    Template.group_edit.events
        'click .delete_item': ->
            if confirm 'delete group?'
                Meteor.call 'delete_group', @_id, ->

        'click .submit': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_group', @_id, =>
                    Router.go "/g/#{@_id}/view"


    # Template.group_edit.helpers
    #     unselected_stewards: ->
    #         Meteor.users.find 
    #             levels:$in:['steward']
if Meteor.isClient
    Template.group_posts.onRendered ->
        Session.setDefault('group_view_layout', 'list')

    Template.group_selector.onCreated ->
        # console.log @
        if @data.name
            @autorun => Meteor.subscribe('doc_by_title_small', @data.name.toLowerCase())
    
    Template.group_selector.helpers
        selector_class: ()->
            term = 
                Docs.findOne 
                    title:@name.toLowerCase()
            if term
                if term.max_emotion_name
                    switch term.max_emotion_name
                        when 'joy' then ' basic green'
                        when 'anger' then ' basic red'
                        when 'sadness' then ' basic blue'
                        when 'disgust' then ' basic orange'
                        when 'fear' then ' basic grey'
                        else 'basic'
        term: ->
            Docs.findOne 
                title:@name.toLowerCase()



    Template.user_groups.onCreated ->
        @autorun -> Meteor.subscribe 'user_group_admin', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_group', Router.current().params.username
        @autorun -> Meteor.subscribe 'authored_groups', Router.current().params.username
    Template.user_groups.helpers
        groups_member: -> 
            user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find 
                model:'group'
                # member_ids:$in:[Meteor.userId()]   
        groups_admin: -> 
            user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find 
                model:'group'
                admin_ids:$in:[Meteor.userId()]   
    
    Template.user_groups.events
        'click .add_group': ->
            new_id = 
                Docs.insert 
                    model:'group'
            Router.go "/g/#{new_id}/edit"
   

if Meteor.isServer
    # Meteor.publish 'authored_groups', (username)->
    #     user = Meteor.users.findOne username:username
    #     match = {
    #         model:'group'
    #         _author_id:Meteor.userId()
    #         # is_private:true
    #         # member_ids:$in:[user._id]
    #     }
    #     Docs.find match,
    #         limit:20
    #         sort:
    #             _timestamp:-1
    Meteor.publish 'user_groups', (username)->
        user = Meteor.users.findOne username:username
        match = {
            model:'group'
            # is_private:true
            member_ids:$in:[user._id]
        }
        Docs.find match,
            limit:20
            sort:
                _timestamp:-1
    
    Meteor.publish 'user_group_admin', (username)->
        user = Meteor.users.findOne username:username
        match = {
            model:'group'
            # is_private:true
            leader_ids:$in:[user._id]
        }
        Docs.find match,
            limit:20
            sort:
                _timestamp:-1
