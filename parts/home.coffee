if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'

            
    # Template.home.onCreated ->
    #     @autorun => Meteor.subscribe 'listings'
    #     # @autorun => Meteor.subscribe 'model_docs', 'finance_stat'
    #     # @autorun => Meteor.subscribe 'model_docs', 'expense'

    #     # @autorun => Meteor.subscribe 'model_docs', 'global_stats'
    #     # @autorun -> Meteor.subscribe('home_tag_results',
    #     #     selected_tags.array()
    #     #     selected_location_tags.array()
    #     #     selected_authors.array()
    #     #     Session.get('view_purchased')
    #     #     # Session.get('view_incomplete')
    #     #     )
    #     # @autorun -> Meteor.subscribe('home_results',
    #     #     selected_tags.array()
    #     #     selected_location_tags.array()
    #     #     selected_authors.array()
    #     #     Session.get('view_purchased')
    #     #     # Session.get('view_incomplete')
    #     #     )
    #     @autorun => Meteor.subscribe 'model_docs', 'listing'

        
    # Template.home.helpers
    #     listings: ->
    #         Docs.find
    #             model:'listing'
    #     featured_products: ->
    #         Docs.find
    #             model:'product'
    #     home_doc: ->
    #         Docs.findOne 
    #             model:'home_doc'
    #     stats_doc: ->
    #         Docs.findOne 
    #             model:'global_stats'
    #     can_debit: ->
    #         Meteor.user().points > 0
    #     latest_debits: ->
    #         Docs.find {
    #             model:'debit'
    #             submitted:true
    #         },
    #             sort:
    #                 _timestamp: -1
    #             limit:25
    #     latest_posts: ->
    #         Docs.find {
    #             model:'post'
    #         },
    #             sort:
    #                 _timestamp: -1
    #             limit:10
    #     next_shifts: ->
    #         Docs.find {
    #             model:'shift'
    #         },
    #             sort:
    #                 _timestamp: -1
    #             limit:10
    #     latest_offers: ->
    #         Docs.find {
    #             model:'offer'
    #         },
    #             sort:
    #                 _timestamp: -1
    #             limit:10
    #     debits: ->
    #         Docs.find
    #             model:'debit'
    
    # Template.home.events
    #     'click .view_debit': ->
    #         Router.go "/debit/#{@_id}/view"
    #     'click .view_request': ->
    #         Router.go "/request/#{@_id}/view"
    #     'click .view_offer': ->
    #         Router.go "/offer/#{@_id}/view"

    #     'click .refresh_stats': ->
    #         Meteor.call 'calc_global_stats'
    #     'click .debit': ->
    #         new_debit_id =
    #             Docs.insert
    #                 model:'debit'
    #         Router.go "/debit/#{new_debit_id}/edit"
    #     'click .request': ->
    #         new_request_id =
    #             Docs.insert
    #                 model:'request'
    #         Router.go "/request/#{new_request_id}/edit"
    #     'click .add_event': ->
    #         new_event_id =
    #             Docs.insert
    #                 model:'event'
    #         Router.go "/event/#{new_event_id}/edit"
    #     'click .offer': ->
    #         new_offer_id =
    #             Docs.insert
    #                 model:'offer'
    #         Router.go "/offer/#{new_offer_id}/edit"
    #     'click .add_expense': ->
    #         new_bug_id =
    #             Docs.insert
    #                 model:'expense'
    #         Router.go "/expense/#{new_bug_id}/edit"
        
    #     'click .add_message': ->
    #         new_message_id =
    #             Docs.insert
    #                 model:'message'
    #         Router.go "/message/#{new_message_id}/edit"

    #     'keydown .find_username': (e,t)->
    #         # email = $('submit_email').val()
    #         if e.which is 13
    #             email = $('.submit_email').val()
    #             if email.length > 0
    #                 Docs.insert
    #                     model:'email_signup'
    #                     email_address:email
    #                 $('body')
    #                   .toast({
    #                     class: 'success'
    #                     position: 'top right'
    #                     message: "#{email} added to list"
    #                   })
    #                 $('.submit_email').val('')



if Meteor.isServer
    Meteor.publish 'event_transactions', (event)->
        # console.log event
        Docs.find 
            model:'transaction'
            event_id:event._id