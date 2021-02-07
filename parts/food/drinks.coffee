if Meteor.isClient
    Router.route "/drinks/:category_slug", (->
        @layout 'layout'
        @render 'drink_category'
        ), name:'drink_category'
    Router.route "/drink_categories", (->
        @layout 'layout'
        @render 'drink_categories'
        ), name:'drink_categories'
    
    
    Router.route "/drink/:doc_id/view", (->
        @layout 'layout'
        @render 'drink_view'
        ), name:'drink_view'
    Router.route "/drink/:doc_id/edit", (->
        @layout 'layout'
        @render 'drink_edit'
        ), name:'drink_edit'
    
    Template.drink_categories.onCreated ->
        @autorun -> Meteor.subscribe 'docs', selected_tags.array(), 'drink'
        @autorun -> Meteor.subscribe 'model_docs', 'drink_category'
    Template.drink_categories.helpers
        drink_items: ->
            Docs.find
                model:'drink'
        drink_categories: ->
            Docs.find
                model:'drink_category'

    Template.drink_categories.events
        'click .new_drink': ->
            new_id = Docs.insert
                model:'drink'
            Router.go "/drink/#{new_id}/edit"

    Template.drink_category.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.drink_category.helpers
        category_drinks: ->
            Docs.find
                model:'drink'

    Template.drink_category.events
        'click .new_drink': ->
            new_id = Docs.insert
                model:'drink'
            Router.go "/drink/#{new_id}/edit"

    Template.drink_card_template.events
        'click .drink_card': ->
            Docs.update @_id,
                $inc:views:1
            Router.go "/drink/#{@_id}/view"


    Template.drink_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'drink_checkin'
    Template.drink_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.drink_view.helpers
        checking_in: -> Session.get('checking_in')
        is_member: ->
            drink = Docs.findOne Router.current().params.doc_id
            if drink.members and Meteor.user().username in drink.members then true else false
        checkins: ->
            Docs.find 
                model:'drink_checkin'
                drink_id: Router.current().params.doc_id

    Template.drink_view.events
        'keyup .adding_checkin': (e,t)->
            if e.which is 13
                drink = Docs.findOne Router.current().params.doc_id
                checkin = t.$('.adding_checkin').val()
                Docs.insert
                    drink_id: drink._id
                    model:'drink_checkin'
                    body:checkin
                Session.set('checking_in', false)
                t.$('.adding_checkin').val('')
    
        'click .checkin_drink': ->
            Session.set('checking_in', true)
        'click .cancel_checkin': ->
            Session.set('checking_in', false)
        'click .join': ->
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    members: Meteor.user().username
        'click .leave': ->
            Docs.update Router.current().params.doc_id,
                $pull:
                    members: Meteor.user().username



    Template.beer_info.onCreated ->
        # console.log @
        # console.log Template.parentData()
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id



    Template.category_selector.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'drink_category'
    Template.category_selector.helpers
        drink_categories: ->
            Docs.find
                model:'drink_category'
        category_class: ->
            # console.log @
            drink = Docs.findOne Router.current().params.doc_id
            if @_id in drink.category_ids then 'active' else ''
    Template.category_selector.events
        'click .select_category':->
            drink = Docs.findOne Router.current().params.doc_id
            console.log Template.parentData()
            console.log @
            if drink.category_ids
                if @_id in drink.category_ids
                    Docs.update drink._id,
                        $pull:category_ids:@_id
                else
                    Docs.update drink._id,
                        $addToSet:category_ids:@_id
            else
                Docs.update drink._id,
                    $addToSet:category_ids:@_id
