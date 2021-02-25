if Meteor.isClient
    Router.route '/bounties/', (->
        @layout 'layout'
        @render 'bounties'
        ), name:'bounties'
    

    Router.route '/b/:doc_id', (->
        @layout 'layout'
        @render 'bounty_view'
        ), name:'bounty_view'

    Template.bounty_view.onCreated ->
        # @autorun => Meteor.subscribe 'product_from_bounty_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
        
    Template.bounty_view.onRendered ->

    Template.bounties.events
        'click .add_bounty': ->
            new_id = Docs.insert 
                model:'bounty'
                parent_id:Router.current().params.doc_id
            Router.go "/b/#{new_id}/edit"
            
    Template.user_bounties.events
        'click .add_bounty': ->
            new_id = Docs.insert 
                model:'bounty'
                parent_id:Router.current().params.doc_id
            Router.go "/b/#{new_id}/edit"
            
    Template.user_bounties.helpers
        bounties: ->
            Docs.find 
                model:'bounty'
                # parent_id:Router.current().params.doc_id
                
                
            
    Template.bounties.helpers
        bounty_docs: ->
            Docs.find 
                model:'bounty'
                parent_id:Router.current().params.doc_id
                
                

if Meteor.isServer
    Meteor.publish 'product_from_bounty_id', (bounty_id)->
        bounty = Docs.findOne bounty_id
        Docs.find 
            _id:bounty.product_id
            
            
            
if Meteor.isClient
    Router.route '/b/:doc_id/edit', (->
        @layout 'layout'
        @render 'bounty_edit'
        ), name:'bounty_edit'
        
        
    Template.bounty_edit.onCreated ->
        @autorun => Meteor.subscribe 'recipient_from_bounty_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users', Router.current().params.doc_id
       
        @autorun => @subscribe 'tag_results',
            # Router.current().params.doc_id
            selected_tags.array()
            Session.get('searching')
            Session.get('current_query')
            Session.get('dummy')
        
    Template.bounty_edit.onRendered ->


    Template.bounty_edit.helpers
        terms: ->
            Terms.find()
        suggestions: ->
            Tags.find()
        recipient: ->
            bounty = Docs.findOne Router.current().params.doc_id
            if bounty.target_id
                Meteor.users.findOne
                    _id: bounty.target_id
        members: ->
            bounty = Docs.findOne Router.current().params.doc_id
            Meteor.users.find({
                # levels: $in: ['member','domain']
                _id: $ne: Meteor.userId()
            }, {
                sort:points:1
                limit:10
                })
        # subtotal: ->
        #     bounty = Docs.findOne Router.current().params.doc_id
        #     bounty.amount*bounty.target_ids.length
        
        point_max: ->
            if Meteor.user().username is 'one'
                1000
            else 
                Meteor.user().points
        
        can_submit: ->
            bounty = Docs.findOne Router.current().params.doc_id
            bounty.amount and bounty.target_id
    Template.bounty_edit.events
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



        'click .cancel_bounty': ->
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
                    Meteor.call 'send_bounty', @_id, =>
                        Swal.fire(
                            title:"#{@amount} sent"
                            icon:'success'
                            showConfirmButton: false
                            position: 'top-end',
                            timer: 1000
                        )
                        Router.go "/b/#{@_id}/view"
            )



if Meteor.isServer
    Meteor.methods
        send_bounty: (bounty_id)->
            bounty = Docs.findOne bounty_id
            recipient = Meteor.users.findOne bounty.target_id
            bountyer = Meteor.users.findOne bounty._author_id

            console.log 'sending bounty', bounty
            Meteor.call 'recalc_one_stats', recipient._id, ->
            Meteor.call 'recalc_one_stats', bounty._author_id, ->
    
            Docs.update bounty_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()
            return
            
            
            
            

                
                
if Meteor.isServer
    Meteor.publish 'post_bounties', (doc_id)->
        found_doc = Docs.findOne doc_id
        if found_doc
            Docs.find 
                model:'bounty'
                parent_id:doc_id            